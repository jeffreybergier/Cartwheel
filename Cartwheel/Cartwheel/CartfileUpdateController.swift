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

protocol CartfileUpdateControllerDelegate: class {
    func cartfileUpdateErrorOcurred(error: CarthageError?)
    func cartfileUpdateInterrupted()
    func cartfileUpdateBuildProgressPercentageChanged(progressPercentage: Double)
    func cartfileUpdateStarted()
    func cartfileUpdateFinished()
}

class CartfileUpdateController {
    let project: Project
    weak var delegate: CartfileUpdateControllerDelegate?
    private var currentOperation: Disposable?
    
    init(delegate: CartfileUpdateControllerDelegate, project: Project) {
        self.delegate = delegate
        self.project = project
    }
    
    func start() {
        self.currentOperation = self.updateCartfileProject(self.project)
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
                println("Dependencies Started")
                self.delegate?.cartfileUpdateStarted()
            })
            |> start(
                error: { error in
                    println("Dependencies Error: \(error)")
                    self.delegate?.cartfileUpdateErrorOcurred(error)
                }, completed: {
                    println("Dependencies Finished.")
                    self.currentOperation = self.buildJobs(jobs)
                }, interrupted: {
                    println("Dependencies Interrupted.")
                    self.delegate?.cartfileUpdateInterrupted()
                }, next: { build in
                    jobs += [build]
            })
    }
    
    private func buildJobs<T, E>(jobs: [SignalProducer<T, E>]) -> Disposable {
        var completedJobs = 0
        return SignalProducer(values: jobs)
            |> flatMap(.Concat) { job in
                return job
                    |> on(completed: {
                        completedJobs++
                        println("\(completedJobs) of \(jobs.count) Finished")
                        self.delegate?.cartfileUpdateBuildProgressPercentageChanged(Double(completedJobs) / Double(jobs.count))
                    })
            }
            |> on(started: {
                println("\(jobs.count) Jobs Started")
                self.delegate?.cartfileUpdateBuildProgressPercentageChanged(Double(completedJobs) / Double(jobs.count))
            })
            |> start(
                error: { error in
                    println("Jobs Error: \(error)")
                    self.delegate?.cartfileUpdateErrorOcurred(error)
                }, completed: {
                    println("\(jobs.count) Jobs Finished")
                    self.delegate?.cartfileUpdateFinished()
                }, interrupted: {
                    println("Jobs Interrupted")
                    self.delegate?.cartfileUpdateInterrupted()
                }, next: { _ in
                    //
            })
    }
}
