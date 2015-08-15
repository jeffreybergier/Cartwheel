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
import XCGLogger
import CarthageKit
import ReactiveCocoa
import ReactiveTask

protocol CartfileUpdateControllerDelegate: class {
    func cartfileUpdateErrorOcurred<E: ErrorType>(error: E?)
    func cartfileUpdateInterrupted()
    func cartfileUpdateBuildProgressPercentageChanged(progressPercentage: Double)
    func cartfileUpdateStarted()
    func cartfileUpdateFinished()
}

protocol CartfileWindowControllable: class {
    var window: NSWindow? { get }
}

final class CartListTableCellViewController: NSTableCellView {
    
    var cartfile: CWCartfile! {
        didSet {
            self.prepareCellForNewModelObject()
            self.updateCellWithNewModelObject()
        }
    }
    
    private let log = XCGLogger.defaultInstance()
    private weak var parentWindow: NSWindow?
    
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
    func configureViewWithWindow(window: NSWindow?) {
        if self.configured == false {
            // set the window
            self.parentWindow = window
            
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
            
            self.updateView.setCancelButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            self.updateView.setWarningButtonAction("didClickShowUpdateWarningsButton:", forTarget: self)
            
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
    private var latestError: NSError?
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {
        if let currentOperation = currentOperation {
            currentOperation.dispose()
            self.currentOperation = .None
        } else {
            self.currentOperation = self.updateCartfileProject(self.cartfile.project)
        }
    }
    
    @objc private func didClickShowUpdateWarningsButton(sender: NSButton) {
        if let error = self.latestError {
            let alert = NSAlert(error: error.nsError)
            dispatch_async(dispatch_get_main_queue()) {
                alert.beginSheetModalForWindow(self.parentWindow!, completionHandler: { untypedResponse in
                    self.log.error("Cartfile Update Error Ocurred. User received Error and then clicked OK: \(error)")
                })
            }
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
                println("Dependencies Started")
                self.cartfileUpdateStarted()
            })
            |> start(
                error: { error in
                    println("Dependencies Error: \(error)")
                    self.cartfileUpdateErrorOcurred(error)
                }, completed: {
                    println("Dependencies Finished.")
                    self.currentOperation = self.buildJobs(jobs)
                }, interrupted: {
                    println("Dependencies Interrupted.")
                    self.cartfileUpdateInterrupted()
                }, next: { build in
                    jobs += [build]
            })
    }
    
    private func buildJobs<T, E: ErrorType>(jobs: [SignalProducer<T, E>]) -> Disposable {
        var completedJobs = 0
        return SignalProducer(values: jobs)
            |> flatMap(.Concat) { job in
                return job
                    |> on(completed: {
                        completedJobs++
                        println("\(completedJobs) of \(jobs.count) Finished")
                        self.cartfileUpdateBuildProgressPercentageChanged(Double(completedJobs) / Double(jobs.count))
                    })
            }
            |> on(started: {
                println("\(jobs.count) Jobs Started")
                self.cartfileUpdateBuildProgressPercentageChanged(Double(completedJobs) / Double(jobs.count))
            })
            |> start(
                error: { error in
                    println("Jobs Error: \(error)")
                    self.cartfileUpdateErrorOcurred(error)
                },
                completed: {
                    println("\(jobs.count) Jobs Finished")
                    self.cartfileUpdateFinished()
                },
                interrupted: {
                    println("Jobs Interrupted")
                    self.cartfileUpdateInterrupted()
                })
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.contentView.viewHeightForTableRowHeightCalculation
    }
}

extension CartListTableCellViewController: CartfileUpdateControllerDelegate {
    func cartfileUpdateErrorOcurred<E: ErrorType>(error: E?) {
        self.currentOperation = .None
        self.latestError = error?.nsError
        self.updateView.state = .Warning
        log.warning("Cartfile Update failed with Error: \(error)")
    }
    func cartfileUpdateInterrupted() {
        self.currentOperation = .None
        self.currentLayout = .Normal
        log.warning("Cartfile Update was Interrupted")
    }
    func cartfileUpdateBuildProgressPercentageChanged(progressPercentage: Double) {
        self.updateView.setProgressIndicatorAnimation(false)
        self.updateView.progressIndicatorType = .Determinate
        self.updateView.progressIndicatorProgress = progressPercentage * 100
    }
    func cartfileUpdateStarted() {
        self.latestError = .None
        self.updateView.progressIndicatorType = .Indeterminate
        self.updateView.setProgressIndicatorAnimation(true)
        self.updateView.state = .Normal
        self.currentLayout = .Updating
    }
    func cartfileUpdateFinished() {
        self.currentOperation = .None
        self.currentLayout = .Normal
    }
}
