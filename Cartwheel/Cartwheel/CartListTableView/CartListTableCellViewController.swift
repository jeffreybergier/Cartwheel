//
//  CartListTableCellViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/28/15.
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

import Cocoa
import PureLayout_Mac
import CarthageKit
import ReactiveCocoa
import ReactiveTask

final class CartListTableCellViewController: NSTableCellView {
        
    let contentView = CartListTableCellView()
    
    var cartfile: CWCartfile! {
        didSet {
            self.prepareCellForNewModelObject()
            self.updateCellWithNewModelObject()
        }
    }
    
    static let identifier = "CartListTableCellViewController"
    override var identifier: String? {
        get { return self.classForCoder.identifier }
        set { /* do nothing */ /* this setter is needed to please the compiler */ }
    }
    
    private func prepareCellForNewModelObject() {
        self.contentView.clearCellContents()
    }
    
    private func updateCellWithNewModelObject() {
        if let cartfileTitle = self.cartfile?.name {
            self.contentView.setPrimaryTextFieldString(cartfileTitle)
        } else {
            self.contentView.clearCellContents()
        }
    }
    
    private var configured = false
    
    func configureViewIfNeeded() {
        if self.configured == false {
            // configure the view
            self.addSubview(self.contentView)
            self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
            self.contentView.viewDidLoad()
            
            // configure the button
            self.contentView.setPrimaryButtonTitle(NSLocalizedString("Update", comment: "Button to perform carthage update"))
            self.contentView.setPrimaryButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            self.configured = true
        }
    }
    
    private var currentOperation: Disposable?
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {
        self.updateCartfileProject(self.cartfile.project)
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
            })
            |> start(
                error: { error in
                    println("Dependencies Error: \(error)")
                }, completed: {
                    println("Dependencies Finished.")
                    self.currentOperation = self.buildJobs(jobs)
                }, interrupted: {
                    println("Dependencies Interrupted.")
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
                        println("\(completedJobs) of \(jobs.count) finished")
                    })
            }
            |> on(started: { println("\(jobs.count) Jobs Started") })
            |> start(
                error: { error in
                    println("Jobs Error: \(error)")
                },
                completed: {
                    println("\(jobs.count) Jobs Finished")
                },
                interrupted: {
                    println("Jobs Interrupted")
                })
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.contentView.viewHeightForTableRowHeightCalculation
    }
}
