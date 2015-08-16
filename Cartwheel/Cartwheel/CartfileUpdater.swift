//
//  CartfileUpdateController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/14/15.
//
//  Copyright (c) 2015 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF COwNTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import CarthageKit
import ReactiveCocoa
import ReactiveTask
import XCGLogger

protocol CartfileUpdateControllerDelegate: class {
    func cartfile(cartfile: CWCartfile, statusChanged status: CartfileUpdater.Status)
}

extension CartfileUpdater: Printable {
    var description: String {
        return "CartfileUpdater <\(self.cartfile.name)>"
    }
}

class CartfileUpdater {
    let cartfile: CWCartfile
    weak var delegate: CartfileUpdateControllerDelegate?
    private var currentOperation: Disposable?
    private let log = XCGLogger.defaultInstance()
    
    init(cartfile: CWCartfile, delegate: CartfileUpdateControllerDelegate) {
        self.delegate = delegate
        self.cartfile = cartfile
    }
    
    enum Status {
        case NotStarted, InProgressIndeterminate, InProgressDeterminate(percentage: Double), FinishedSuccess, FinishedInterrupted, FinishedError(error: ErrorType), NonExistant
    }
    
    private(set) var status = Status.NotStarted {
        didSet {
            self.delegate?.cartfile(self.cartfile, statusChanged: self.status)
        }
    }
    
    func start() {
        self.currentOperation = self.updateCartfileProject(self.cartfile.project)
    }
    
    func cancel() {
        self.currentOperation?.dispose()
        self.currentOperation = .None
    }

    private func updateCartfileProject(project: Project) -> Disposable {
        var jobs = [SignalProducer<TaskEvent<(ProjectLocator, String)>, CarthageError>]()
        //var jobs = [SignalProducer<T, ErrorType>]()
        return project.updateDependencies()
            |> then(SignalProducer(values: [
                project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .Mac),
                project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .iOS),
                project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .watchOS)
                ])
            )
            |> flatten(.Concat)
            |> on(started: {
                self.log.info("\(self): Downloading Dependencies Started")
                self.status = .InProgressIndeterminate
            })
            |> ReactiveCocoa.start(
                error: { error in
                    self.log.warning("\(self): Downloading Dependencies Failed with Error: \(error)")
                    self.status = .FinishedError(error: error)
                }, completed: {
                    self.log.info("\(self): Downloading Dependencies Finished")
                    self.currentOperation = self.buildJobs(jobs)
                }, interrupted: {
                    self.log.warning("\(self): Downloading Dependencies Interrupted")
                    self.status = .FinishedInterrupted
                }, next: { build in
                    jobs += [build]
            })
    }
    
    private func buildJobs<T, E>(jobs: [SignalProducer<T, E>]) -> Disposable {
        var completedJobs = 0
        return SignalProducer(values: jobs)
            |> flatMap(.Concat) { job -> SignalProducer<T, E> in
                return job
                    |> on(completed: {
                        completedJobs++
                        self.log.info("\(self): Compiling \(completedJobs) of \(jobs.count)")
                        self.status = .InProgressDeterminate(percentage: Double(completedJobs) / Double(jobs.count))
                    })
            }
            |> on(started: {
                self.log.info("\(self): Compiling Started")
                self.status = .InProgressDeterminate(percentage: Double(completedJobs) / Double(jobs.count))
            })
            |> ReactiveCocoa.start(
                error: { error in
                    self.log.warning("\(self): Compiling Failed with Error: \(error)")
                    self.status = .FinishedError(error: error)
                }, completed: {
                    self.log.info("\(self): Compiling Finished")
                    self.status = .FinishedSuccess
                }, interrupted: {
                    self.log.warning("\(self): Compiling Interrupted")
                    self.status = .FinishedInterrupted
            })
    }
}
