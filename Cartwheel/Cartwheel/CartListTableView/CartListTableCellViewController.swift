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
    
    private let contentView = CartListTableCellView()
    private let updateView = CartListTableCellUpdatingView()
    
    private var normalLayoutConstraints = [NSLayoutConstraint]()
    private var updatingLayoutConstraints = [NSLayoutConstraint]()
    private var currentLayout: Layout = .Normal {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true
                    switch self.currentLayout {
                    case .Normal:
                        self.removeConstraints(self.updatingLayoutConstraints)
                        self.addConstraints(self.normalLayoutConstraints)
                    case .Updating:
                        self.removeConstraints(self.normalLayoutConstraints)
                        self.addConstraints(self.updatingLayoutConstraints)
                    }
                    self.layoutSubtreeIfNeeded()
                }, completionHandler: nil)
            }
        }
    }
    
    enum Layout {
        case Normal, Updating
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
            // add the views
            self.addSubview(self.contentView)
            self.addSubview(self.updateView)
            
            // configure the constraints
            self.configureConstraints()
            
            // configure the views
            self.contentView.viewDidLoad()
            self.updateView.viewDidLoad()
            
            // configure the button
            self.contentView.setPrimaryButtonTitle(NSLocalizedString("Update", comment: "Button to perform carthage update"))
            self.contentView.setPrimaryButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            
            self.updateView.setPrimaryButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            
            // done configuring, don't do it again when cell is recycled
            self.configured = true
        }
    }
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        self.updatingLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.contentView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.contentView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            self.contentView.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.updateView, withOffset: 0)
            
            self.updateView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.updateView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 0)
            self.updateView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            
            self.contentView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            self.updateView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            
            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.normalLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.contentView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.contentView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 0)
            self.contentView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            self.contentView.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.updateView, withOffset: 0)
            
            self.updateView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.updateView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            
            self.contentView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            self.updateView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)

            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.addConstraints(self.normalLayoutConstraints)
    }
    
    private var currentOperation: Disposable?
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {
        if let currentOperation = currentOperation {
            currentOperation.dispose()
            self.currentOperation = .None
        } else {
            self.currentOperation = self.updateCartfileProject(self.cartfile.project)
        }
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
                self.currentLayout = .Updating
                println("Dependencies Started")
            })
            |> start(
                error: { error in
                    self.currentLayout = .Normal
                    println("Dependencies Error: \(error)")
                }, completed: {
                    println("Dependencies Finished.")
                    self.currentOperation = self.buildJobs(jobs)
                }, interrupted: {
                    self.currentLayout = .Normal
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
                        println("\(completedJobs) of \(jobs.count) Finished")
                    })
            }
            |> on(started: {
                self.currentLayout = .Updating
                println("\(jobs.count) Jobs Started")
            })
            |> start(
                error: { error in
                    self.currentLayout = .Normal
                    println("Jobs Error: \(error)")
                },
                completed: {
                    self.currentLayout = .Normal
                    println("\(jobs.count) Jobs Finished")
                },
                interrupted: {
                    self.currentLayout = .Normal
                    println("Jobs Interrupted")
                })
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.contentView.viewHeightForTableRowHeightCalculation
    }
}
