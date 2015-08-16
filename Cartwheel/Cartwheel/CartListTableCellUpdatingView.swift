//
//  CartListTableCellUpdatingView.swift
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

import Cocoa
import PureLayout_Mac

class CartListTableCellUpdatingView: NSView {
    
    private let cancelButton = NSButton(style: .Cancel)
    private let retryButton = NSButton(style: .Retry)
    private let warningButton = NSButton(style: .Warning)
    private let buttonStackView = NSStackView()
    private let progressIndicator = NSProgressIndicator()
    private var viewConstraints = [NSLayoutConstraint]()
    
    func viewDidLoad() {
        self.wantsLayer = true
        
        self.progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.retryButton.translatesAutoresizingMaskIntoConstraints = false
        self.warningButton.translatesAutoresizingMaskIntoConstraints = false
        self.buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.progressIndicator)
        self.addSubview(self.buttonStackView)
        
        self.buttonStackView.orientation = .Horizontal
        self.buttonState = .Normal
        self.progressIndicatorState = .Determinate
        self.progressIndicatorProgress = 0
        
        self.configureLayoutConstraints()
    }
    
    private func configureLayoutConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        self.viewConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.buttonStackView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset)
            self.buttonStackView.autoPinEdgeToSuperviewEdge(.Top, withInset: smallInset)
            self.buttonStackView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: smallInset)
            
            self.progressIndicator.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
            self.progressIndicator.autoPinEdgeToSuperviewEdge(.Top, withInset: smallInset)
            self.progressIndicator.autoPinEdgeToSuperviewEdge(.Bottom, withInset: smallInset)
            
            self.buttonStackView.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.progressIndicator, withOffset: defaultInset)

            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.addConstraints(self.viewConstraints)
    }
    
    // MARK: Internal Methods to be used by controller
    
    enum State {
        case Normal, Warning
    }
    
    private var _buttonState: State = .Normal
    var buttonState: State {
        set {
            _buttonState = newValue
            dispatch_async(dispatch_get_main_queue()) {
                for view in self.buttonStackView.views {
                    self.buttonStackView.removeView(view as! NSView)
                }
                switch newValue {
                case .Normal:
                    self.buttonStackView.addView(self.cancelButton, inGravity: .Bottom)
                case .Warning:
                    self.buttonStackView.addView(self.retryButton, inGravity: .Bottom)
                    self.buttonStackView.addView(self.warningButton, inGravity: .Top)
                }
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true
                    self.layoutSubtreeIfNeeded()
                }, completionHandler: nil)
            }
        }
        get {
            return _buttonState
        }
    }
    
    var progressIndicatorState: NSProgressIndicator.IndicatorState {
        get {
            switch self.progressIndicator.indeterminate {
            case false:
                return .Determinate
            default:
                return .Indeterminate
            }
        }
        set {
            switch newValue {
            case .Indeterminate:
                self.progressIndicator.indeterminate = true
            case .Determinate:
                self.progressIndicator.indeterminate = false
            }
        }
    }
    
    func setProgressIndicatorAnimation(animating: Bool) {
        switch animating {
        case true:
            self.progressIndicator.startAnimation(nil)
        default:
            self.progressIndicator.stopAnimation(nil)
        }
    }
    
    var progressIndicatorProgress: Double {
        get {
            return self.progressIndicator.doubleValue
        }
        set {
            dispatch_async(dispatch_get_main_queue()) {
                self.progressIndicator.doubleValue = newValue
            }
        }
    }
    
    func setCancelButtonAction(action: Selector, forTarget target: NSObject) {
        self.cancelButton.target = target
        self.cancelButton.action = action
        self.retryButton.target = target
        self.retryButton.action = action
    }
    
    func setWarningButtonAction(action: Selector, forTarget target: NSObject) {
        self.warningButton.target = target
        self.warningButton.action = action
    }
    
}