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
import PureLayout_Mac

class CartListTableCellView: NSView {
    
    // MARK: Load and Configure the Views for this Row
    
    private let ui = InterfaceElements()
    private var viewConstraints = [NSLayoutConstraint]()
    private weak var cellViewController: NSTableCellView?
    
    func viewDidLoadWithController(controller: NSTableCellView?) {
        self.wantsLayer = true
        
        self.cellViewController = controller
        self.addSubview(self.ui.stackView)
        self.configureStackView(self.ui.stackView, withViews: self.ui.allViewsWithinStackView)
        self.configurePrimartTextField(self.ui.primaryTextField)
        self.configurePrimaryButton(self.ui.primaryButton)
        self.configureLayoutConstraints()
    }
    
    // MARK: Handle View Contents
    
    func clearContents() {
        self.ui.primaryTextField.stringValue = ""
    }
    
    func populatePrimaryTextFieldWithString(newPrimaryTextFieldString: String) {
        self.ui.primaryTextField.stringValue = newPrimaryTextFieldString
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.ui.stackView.frame.size.height
    }
    
    // MARK: Handle View Configuration
    
    private func configureLayoutConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Top, withInset: smallInset)
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset)
        }
        
        let optionalPureLayoutConstraints = pureLayoutConstraints.map { (object) -> NSLayoutConstraint? in
            if let constraint = object as? NSLayoutConstraint {
                return constraint
            } else {
                return nil
            }
        }
        
        self.viewConstraints = Array.filterOptionals(optionalPureLayoutConstraints)
        self.addConstraints(self.viewConstraints)
    }
    
    private func configurePrimartTextField(primartTextField: NSTextField) {
        if let _ = primartTextField.superview {
            primartTextField.bordered = false
            (primartTextField.cell() as? NSTextFieldCell)?.drawsBackground = false
            primartTextField.editable = false
            primartTextField.font = NSFont.systemFontOfSize(NSFont.systemFontSize())
        } else {
            fatalError("\(self): Tried to configure test label before it was in the view hierarchy.")
        }
    }
    
    private func configurePrimaryButton(primaryButton: NSButton) {
        if let _ = primaryButton.superview {
            primaryButton.setButtonType(.MomentaryPushInButton)
            primaryButton.bezelStyle = .RoundedBezelStyle
            primaryButton.title = NSLocalizedString("Update", comment: "Button to perform carthage update")
            primaryButton.target = self.cellViewController
            primaryButton.action = "didClickCreateNewCartFileButton:"
            (primaryButton.cell() as? NSButtonCell)?.backgroundColor = NSColor.clearColor()
        } else {
            fatalError("\(self): Tried to configure updateButton before it was in the view hierarchy.")
        }
    }
    
    private func configureStackView(stackView: NSStackView, withViews views: [NSView]) {
        if let _ = stackView.superview {
            stackView.orientation = .Horizontal
            for view in views {
                if let view = view as? NSButton {
                    stackView.addView(view, inGravity: .Bottom)
                } else {
                    stackView.addView(view, inGravity: .Top)
                }
            }
        } else {
            fatalError("\(self): Tried to configure the filterField before it was in the view hierarchy.")
        }
    }
    
    struct InterfaceElements {
        var primaryTextField = NSTextField()
        var primaryButton = NSButton()
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