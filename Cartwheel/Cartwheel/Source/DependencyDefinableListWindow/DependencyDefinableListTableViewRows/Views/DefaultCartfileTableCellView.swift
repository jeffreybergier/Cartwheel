//
//  CartListTableCellView.swift
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
import PureLayout

final class DefaultCartfileTableCellView: NSView {
    
    // MARK: Load and Configure the Views for this Row
    
    private let ui = InterfaceElements()
    private var viewConstraints = [NSLayoutConstraint]()
    
    func viewDidLoad() {
        self.wantsLayer = true
        
        self.addSubview(self.ui.stackView)
        self.configureStackView(self.ui.stackView, withViews: self.ui.allViewsWithinStackView)
        self.configurePrimartTextField(self.ui.primaryTextField)
        self.configureLayoutConstraints()
    }
    
    private func configureLayoutConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        let newConstraints = NSLayoutConstraint.autoCreateConstraintsWithoutInstalling() {
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Top, withInset: smallInset)
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset)
            }.filter() { object -> Bool in
                if let contraint = object as? NSLayoutConstraint { return true } else { return false }
            }.map() { object -> NSLayoutConstraint in
                return object as! NSLayoutConstraint
        }
        
        self.viewConstraints += newConstraints
        self.addConstraints(self.viewConstraints)
    }
    
    // MARK: Public Interface for Controller
    
    func clearCellContents() {
        self.ui.primaryTextField.stringValue = ""
    }
    
    func setPrimaryTextFieldString(newString: String) {
        self.ui.primaryTextField.stringValue = newString
    }
    
    func setPrimaryButtonTitle(newTitle: String) {
        self.ui.primaryButton.title = newTitle
    }
    
    func setPrimaryButtonAction(action: Selector, forTarget target: AnyObject) {
        self.ui.primaryButton.target = target
        self.ui.primaryButton.action = action
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.ui.stackView.frame.size.height
    }
    
    // MARK: Handle Subview Configuration
    
    private func configurePrimartTextField(primartTextField: NSTextField) {
        primartTextField.font = NSFont.systemFontOfSize(NSFont.systemFontSize())
    }
    
    private func configureStackView(stackView: NSStackView, withViews views: [NSView]) {
        stackView.orientation = .Horizontal
        for view in views {
            if let view = view as? NSButton {
                stackView.addView(view, inGravity: .Bottom)
            } else {
                stackView.addView(view, inGravity: .Top)
            }
        }
    }
    
    struct InterfaceElements {
        var primaryTextField = NSTextField(style: .TableRowCellTitle)
        var primaryButton = NSButton(style: .Default)
        var stackView = NSStackView()
        var allViewsWithinStackView: [NSView]
        var allViews: [NSView]
        
        init() {
            let allViewsWithinStackView: [NSView] = [self.primaryTextField, self.primaryButton]
            self.allViewsWithinStackView = allViewsWithinStackView
            self.allViews = allViewsWithinStackView + [stackView]
            for view in self.allViews {
                view.wantsLayer = true
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
}