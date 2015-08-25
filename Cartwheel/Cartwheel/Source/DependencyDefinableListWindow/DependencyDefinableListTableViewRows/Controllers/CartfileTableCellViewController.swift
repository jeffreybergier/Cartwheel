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

protocol CartfileWindowControllable: class {
    var window: NSWindow? { get }
}

final class CartfileTableCellViewController: NSObject {
    
    weak var view: NSTableCellView!
    
    var cartfile: Cartfile! {
        didSet {
            self.prepareCellForNewModelObject()
            self.updateCellWithNewModelObject()
        }
    }
    
    private let log = XCGLogger.defaultInstance()
    private weak var parentWindow: NSWindow!
    private weak var cartfileUpdaterManager: CartfileUpdaterManager!
    
    private let defaultView = DefaultCartfileTableCellView()
    private let updatingView = UpdatingCartfileTableCellView()
    
    private var cartfileUpdateStatus: CartfileUpdater.Status = .NonExistant {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                switch self.cartfileUpdateStatus {
                case .NotStarted:
                    self.switchToNormalLayout()
                    self.updatingView.progressIndicatorState = .Determinate
                    self.updatingView.progressIndicatorProgress = 0
                    self.updatingView.buttonState = .Normal
                case .InProgressIndeterminate:
                    self.updatingView.progressIndicatorState = .Indeterminate
                    self.updatingView.buttonState = .Normal
                    self.switchToUpdatingLayout()
                case .InProgressDeterminate(let percentage):
                    self.updatingView.progressIndicatorState = .Determinate
                    self.updatingView.progressIndicatorProgress = percentage * 100
                    self.updatingView.buttonState = .Normal
                    self.switchToUpdatingLayout()
                case .FinishedSuccess:
                    self.switchToNormalLayout()
                    self.updatingView.progressIndicatorState = .Determinate
                    self.updatingView.progressIndicatorProgress = 0
                    self.updatingView.buttonState = .Normal
                case .FinishedInterrupted:
                    self.switchToNormalLayout()
                    self.updatingView.progressIndicatorState = .Determinate
                    self.updatingView.progressIndicatorProgress = 0
                    self.updatingView.buttonState = .Normal
                case .FinishedError(let error):
                    self.updatingView.progressIndicatorState = .Determinate
                    self.updatingView.buttonState = .Warning
                    self.switchToUpdatingLayout()
                case .NonExistant:
                    self.switchToNormalLayout()
                    self.updatingView.progressIndicatorState = .Determinate
                    self.updatingView.progressIndicatorProgress = 0
                    self.updatingView.buttonState = .Normal
                }
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true
                    self.view.layoutSubtreeIfNeeded()
                    }, completionHandler: nil)
            }
        }
    }
    
    private func cartfileUpdateStatusChanged(cartfile: Cartfile) {
        if self.cartfile == cartfile { // don't do anything if the cartfile update is not mine
            if let status = self.cartfileUpdaterManager?.statusForCartfile(cartfile) {
                self.cartfileUpdateStatus = status
            } else {
                self.cartfileUpdateStatus = .NonExistant
            }
        }
    }
    
    private func prepareCellForNewModelObject() {
        self.cartfileUpdateStatus = .NonExistant
        self.defaultView.clearCellContents()
    }
    
    private func updateCellWithNewModelObject() {
        if let cartfile = self.cartfile {
            self.cartfileUpdateStatusChanged(cartfile)
            self.defaultView.setPrimaryTextFieldString(cartfile.name)
        } else {
            self.defaultView.clearCellContents()
        }
    }
    
    private var configured = false
    func configureViewWithWindow(window: NSWindow, updateController controller: CartfileUpdaterManager) {
        if self.configured == false {
            // set the window
            self.parentWindow = window
            
            // register with the observer
            self.cartfileUpdaterManager = controller
            self.cartfileUpdaterManager?.changeNotifier.add(self, self.dynamicType.cartfileUpdateStatusChanged)
            
            // add the views
            self.view.addSubview(self.defaultView)
            self.view.addSubview(self.updatingView)
            
            // configure the constraints
            self.configureConstraints()
            
            // configure the views
            self.defaultView.viewDidLoad()
            self.updatingView.viewDidLoad()
            
            // configure the button
            self.defaultView.setPrimaryButtonTitle(NSLocalizedString("Update", comment: "Button to perform carthage update"))
            self.defaultView.setPrimaryButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            
            self.updatingView.setCancelButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            self.updatingView.setWarningButtonAction("didClickShowUpdateWarningsButton:", forTarget: self)
            
            // done configuring, don't do it again when cell is recycled
            self.configured = true
        }
    }
    
    private var normalLayoutConstraints = [NSLayoutConstraint]()
    private var updatingLayoutConstraints = [NSLayoutConstraint]()
    
    private func switchToUpdatingLayout() {
        self.view.removeConstraints(self.normalLayoutConstraints)
        self.view.addConstraints(self.updatingLayoutConstraints)
    }
    
    private func switchToNormalLayout() {
        self.view.removeConstraints(self.updatingLayoutConstraints)
        self.view.addConstraints(self.normalLayoutConstraints)
    }
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        self.updatingLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.defaultView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.defaultView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            self.defaultView.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.updatingView, withOffset: 0)
            
            self.updatingView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.updatingView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 0)
            self.updatingView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            
            self.defaultView.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            self.updatingView.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            
            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.normalLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.defaultView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.defaultView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 0)
            self.defaultView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            self.defaultView.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.updatingView, withOffset: 0)
            
            self.updatingView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            self.updatingView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            
            self.defaultView.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            self.updatingView.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)

            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.view.addConstraints(self.normalLayoutConstraints)
    }
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {
        switch self.cartfileUpdaterManager.statusForCartfile(self.cartfile) {
        case .NonExistant, .NotStarted, .FinishedSuccess, .FinishedInterrupted, .FinishedError(let _):
            self.cartfileUpdaterManager.updateCartfile(self.cartfile, forceRestart: true)
        case .InProgressIndeterminate, .InProgressDeterminate(let _):
            self.cartfileUpdaterManager.cancelUpdateForCartfile(self.cartfile)
        }
    }
    
    @objc private func didClickShowUpdateWarningsButton(sender: NSButton) {
        switch self.cartfileUpdaterManager.statusForCartfile(self.cartfile) {
        case .FinishedError(let error):
            let alert = NSAlert(error: error.nsError)
            alert.addButtonWithTitle(NSLocalizedString("Dismiss and Clear Error", comment: "Primary button in the build error alert box that closes the box and clears the error"))
            alert.addButtonWithTitle(NSLocalizedString("Dismiss", comment: "Second button in the build error alert box that closes the box and does not clear the error"))
            dispatch_async(dispatch_get_main_queue()) {
                alert.beginSheetModalForWindow(self.parentWindow, completionHandler: { untypedResponse in
                    if let response = NSAlert.Style.CartfileBuildErrorDismissResponse(rawValue: Int(untypedResponse.value)) {
                        switch response {
                        case .DismissButton:
                            self.log.error("Cartfile Update Error Ocurred. User received Error and then clicked dismiss: \(error)")
                        case .DismissAndClearButton:
                            self.log.error("Cartfile Update Error Ocurred. User received Error and then clicked dismiss and clear: \(error)")
                            self.cartfileUpdaterManager?.cancelUpdateForCartfile(self.cartfile)
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
        return self.defaultView.viewHeightForTableRowHeightCalculation
    }
}
