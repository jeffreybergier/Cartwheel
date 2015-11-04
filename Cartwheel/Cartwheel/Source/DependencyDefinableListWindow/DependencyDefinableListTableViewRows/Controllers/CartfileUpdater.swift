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
import ObserverSet

// MARK: Delegate Protocol
protocol CartfileUpdaterDelegate: class {
    var changeNotifier: ObserverSet<Cartfile> { get }
}

class CartfileUpdater {
    // MARK: Logging
    private let log = XCGLogger.defaultInstance()
    
    // MARK: Cartfile storage
    let cartfile: Cartfile
    private lazy var project: Project = {
        return Project(directoryURL: self.cartfile.location)
    }()
    
    // MARK: Initialization
    init(cartfile: Cartfile, delegate: CartfileUpdaterDelegate) {
        self.delegate = delegate
        self.cartfile = cartfile
    }
    
    // MARK: Handle Starting and Stopping
    private var currentOperation: Disposable?
    
    func start() {
        self.currentOperation = self.updateCartfileProject(self.project)
    }
    
    func cancel() {
        self.currentOperation?.dispose()
        self.currentOperation = .None
    }
    
    // MARK: Notify the Delegate of Changes
    weak var delegate: CartfileUpdaterDelegate?
    
    private(set) var status = Status.NotStarted {
        didSet {
            self.delegate?.changeNotifier.notify(self.cartfile)
        }
    }
    
    // MARK: Do the actual work
    private func updateCartfileProject(project: Project) -> Disposable {
        // get updates to log
        project.projectEvents
        |> observe(next: { event in
            switch event {
            case .Cloning(let id):
                self.log.info("\(self): Cloning: \(id.name)")
            case .Fetching(let id):
                self.log.info("\(self): Fetching: \(id.name)")
            case .CheckingOut(let id, let version):
                self.log.info("\(self): Checking Out: \(id.name) \(version)")
            case .DownloadingBinaries(let id, let version):
                self.log.info("\(self): Downloading Binaries: \(id.name) \(version)")
            case .SkippedDownloadingBinaries(let id, let version):
                self.log.info("\(self): Skipped Downloading Binaries: \(id.name) \(version)")
            case .SkippedBuilding(let id, let version):
                self.log.info("\(self): Skipped Building: \(id.name) \(version)")
                // TODO: Need to make a place that the user can click to see warnings
                // as opposed to errors
            }
        })
        
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
    
    private func buildJobs(jobs: [SignalProducer<TaskEvent<(ProjectLocator, String)>, CarthageError>]) -> Disposable {
        var completedJobs = 0
        return SignalProducer(values: jobs)
            |> flatMap(.Concat) { job in
                return job
                    |> on(completed: {
                        completedJobs++
                        self.log.info("\(self): Compiling \(completedJobs) of \(jobs.count)")
                        self.status = .InProgressDeterminate(percentage: Double(completedJobs) / Double(jobs.count))
                    })
                    |> on(next: { location in
                        if let name = location.value?.1 {
                            self.log.info("\(self): Successfuly Compiled: \(name)")
                        }
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
    
    // MARK: Internal Enum
    enum Status {
        case NotStarted,
        InProgressIndeterminate,
        InProgressDeterminate(percentage: Double),
        FinishedSuccess,
        FinishedInterrupted,
        FinishedError(error: ErrorType),
        NonExistant
    }
}


// MARK: Printable
extension CartfileUpdater: CustomStringConvertible {
    var description: String {
        return "CartfileUpdater <\(self.cartfile.name)>"
    }
}
