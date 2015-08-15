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
    
    private let primaryButton = NSButton(roundedBezelStyle: true)
    private let progressIndicator = NSProgressIndicator()
    private var viewConstraints = [NSLayoutConstraint]()
    
    func viewDidLoad() {
        self.wantsLayer = true
        self.progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.progressIndicator)
        self.addSubview(self.primaryButton)
        
        self.configureLayoutConstraints()
    }
    
    private func configureLayoutConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        self.viewConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.primaryButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset)
            self.primaryButton.autoPinEdgeToSuperviewEdge(.Top, withInset: smallInset)
            self.primaryButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: smallInset)
            
            self.progressIndicator.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
            self.progressIndicator.autoPinEdgeToSuperviewEdge(.Top, withInset: smallInset)
            self.progressIndicator.autoPinEdgeToSuperviewEdge(.Bottom, withInset: smallInset)
            
            self.primaryButton.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.progressIndicator, withOffset: defaultInset)

            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.addConstraints(self.viewConstraints)
    }
    
    // MARK: Internal Methods to be used by controller
    
    var progressIndicatorType: NSProgressIndicator.IndicatorType {
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
    
    func setPrimaryButtonAction(action: Selector, forTarget target: NSObject) {
        self.primaryButton.target = target
        self.primaryButton.action = action
    }
    
    func setPrimaryButtonTitle(newTitle: String) {
        self.primaryButton.title = newTitle
    }
    
}