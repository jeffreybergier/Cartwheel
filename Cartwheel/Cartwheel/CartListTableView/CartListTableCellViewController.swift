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
    private weak var cartfileUpdateController: CartfileUpdaterController?
    
    static let identifier = "CartListTableCellViewController"
    override var identifier: String? {
        get { return self.classForCoder.identifier }
        set { /* do nothing */ /* this setter is needed to please the compiler */ }
    }
    
    private let contentView = CartListTableCellView()
    private let updateView = CartListTableCellUpdatingView()
    
    private var normalLayoutConstraints = [NSLayoutConstraint]()
    private var updatingLayoutConstraints = [NSLayoutConstraint]()
    
    private func switchToUpdatingLayout() {
        self.removeConstraints(self.normalLayoutConstraints)
        self.addConstraints(self.updatingLayoutConstraints)
    }
    
    private func switchToNormalLayout() {
        self.removeConstraints(self.updatingLayoutConstraints)
        self.addConstraints(self.normalLayoutConstraints)
    }
    
    private var performAnimationWhenChangingState = true
    private var cartfileUpdateStatus: CartfileUpdater.Status = .NonExistant {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                switch self.cartfileUpdateStatus {
                case .NotStarted:
                    self.switchToNormalLayout()
                    self.updateView.progressIndicatorState = .Determinate
                    self.updateView.progressIndicatorProgress = 0
                    self.updateView.buttonState = .Normal
                case .InProgressIndeterminate:
                    self.updateView.progressIndicatorState = .Indeterminate
                    self.updateView.buttonState = .Normal
                    self.switchToUpdatingLayout()
                case .InProgressDeterminate(let percentage):
                    self.updateView.progressIndicatorState = .Determinate
                    self.updateView.progressIndicatorProgress = percentage * 100
                    self.updateView.buttonState = .Normal
                    self.switchToUpdatingLayout()
                case .FinishedSuccess:
                    self.switchToNormalLayout()
                    self.updateView.progressIndicatorState = .Determinate
                    self.updateView.progressIndicatorProgress = 0
                    self.updateView.buttonState = .Normal
                case .FinishedInterrupted:
                    self.switchToNormalLayout()
                    self.updateView.progressIndicatorState = .Determinate
                    self.updateView.progressIndicatorProgress = 0
                    self.updateView.buttonState = .Normal
                case .FinishedError(let error):
                    self.updateView.progressIndicatorState = .Determinate
                    self.updateView.buttonState = .Warning
                    self.switchToUpdatingLayout()
                case .NonExistant:
                    self.switchToNormalLayout()
                    self.updateView.progressIndicatorState = .Determinate
                    self.updateView.progressIndicatorProgress = 0
                    self.updateView.buttonState = .Normal
                }
                if self.performAnimationWhenChangingState == true {
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.3
                        context.allowsImplicitAnimation = true
                        self.layoutSubtreeIfNeeded()
                    }, completionHandler: nil
                    )
                } else {
                    self.performAnimationWhenChangingState = true
                }
            }
        }
    }
    
    private func cartfileUpdateStatusChanged(cartfile: CWCartfile) {
        if self.cartfile == cartfile { // don't do anything if the cartfile update is not mine
            if let status = self.cartfileUpdateController?.statusForCartfile(cartfile) {
                self.cartfileUpdateStatus = status
            } else {
                self.cartfileUpdateStatus = .NonExistant
            }
        }
    }
    
    private func prepareCellForNewModelObject() {
        self.performAnimationWhenChangingState = false
        self.cartfileUpdateStatus = .NonExistant
        self.contentView.clearCellContents()
    }
    
    private func updateCellWithNewModelObject() {
        if let cartfile = self.cartfile {
            self.performAnimationWhenChangingState = false
            self.cartfileUpdateStatusChanged(cartfile)
            self.contentView.setPrimaryTextFieldString(cartfile.name)
        } else {
            self.contentView.clearCellContents()
        }
    }
    
    private var configured = false
    func configureViewWithWindow(window: NSWindow?, updateController controller: CartfileUpdaterController?) {
        if self.configured == false {
            // set the window
            self.parentWindow = window
            
            // register with the observer
            self.cartfileUpdateController = controller
            self.cartfileUpdateController?.updateObserver.add(self, self.dynamicType.cartfileUpdateStatusChanged)
            
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
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {
        switch self.cartfileUpdateController!.statusForCartfile(self.cartfile) {
        case .NonExistant, .NotStarted, .FinishedSuccess, .FinishedInterrupted, .FinishedError(let _):
            self.cartfileUpdateController?.updateCartfile(self.cartfile, forceRestart: true)
        case .InProgressIndeterminate, .InProgressDeterminate(let _):
            self.cartfileUpdateController?.cancelUpdateForCartfile(self.cartfile)
        }
    }
    
    @objc private func didClickShowUpdateWarningsButton(sender: NSButton) {
        switch self.cartfileUpdateController!.statusForCartfile(self.cartfile) {
        case .FinishedError(let error):
            let alert = NSAlert(error: error.nsError)
            alert.addButtonWithTitle(NSLocalizedString("Dismiss and Clear Error", comment: "Primary button in the build error alert box that closes the box and clears the error"))
            alert.addButtonWithTitle(NSLocalizedString("Dismiss", comment: "Second button in the build error alert box that closes the box and does not clear the error"))
            dispatch_async(dispatch_get_main_queue()) {
                alert.beginSheetModalForWindow(self.parentWindow!, completionHandler: { untypedResponse in
                    if let response = NSAlert.Style.CartfileBuildErrorDismissResponse(rawValue: Int(untypedResponse.value)) {
                        switch response {
                        case .DismissButton:
                            self.log.error("Cartfile Update Error Ocurred. User received Error and then clicked dismiss: \(error)")
                        case .DismissAndClearButton:
                            self.log.error("Cartfile Update Error Ocurred. User received Error and then clicked dismiss and clear: \(error)")
                            self.cartfileUpdateController?.cancelUpdateForCartfile(self.cartfile)
                        }
                    }
                })
            }
        default:
            break
        }
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.contentView.viewHeightForTableRowHeightCalculation
    }
}
