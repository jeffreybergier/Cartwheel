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
    
    let ui = InterfaceElements()
    var viewConstraints = [NSLayoutConstraint]()
    weak var controller: NSView?
    
    func viewDidLoadWithController(controller: NSView?) {
        self.wantsLayer = true
        
        self.controller = controller
        self.addSubview(self.ui.stackView)
        self.configure(stackView: self.ui.stackView, withViews: self.ui.allViewsWithinStackView)
        self.configure(cartfileTitleLabel: self.ui.cartfileTitleLabel)
        self.configure(updateButton: self.ui.updateButton)
        self.configureLayoutConstraints()
    }
    
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
    
    private func configure(#cartfileTitleLabel: NSTextField) {
        if let _ = cartfileTitleLabel.superview {
            cartfileTitleLabel.bordered = false
            (cartfileTitleLabel.cell() as? NSTextFieldCell)?.drawsBackground = false
            cartfileTitleLabel.editable = false
            cartfileTitleLabel.font = NSFont.systemFontOfSize(NSFont.systemFontSize())
        } else {
            fatalError("CartListTableCellView: Tried to configure test label before it was in the view hierarchy.")
        }
    }
    
    private func configure(#updateButton: NSButton) {
        if let _ = updateButton.superview {
            updateButton.setButtonType(.MomentaryPushInButton)
            updateButton.bezelStyle = .RoundedBezelStyle
            updateButton.title = NSLocalizedString("Update", comment: "Button to perform carthage update")
            updateButton.target = self.controller
            updateButton.action = "didClickCreateNewCartFileButton:"
            (updateButton.cell() as? NSButtonCell)?.backgroundColor = NSColor.clearColor()
        } else {
            fatalError("CartListTableCellView: Tried to configure updateButton before it was in the view hierarchy.")
        }
    }
    
    private func configure(#stackView: NSStackView, withViews views: [NSView]) {
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
            fatalError("CartListView: Tried to configure the filterField before it was in the view hierarchy.")
        }
    }
    
    func clearCellView() {
        self.ui.cartfileTitleLabel.stringValue = ""
        //self.cellWasDeselected()
    }
    
    // MARK: Handle Legacy View Selection Behavior
    
//
//    func cellWasDeselected() {
//        self.layer?.backgroundColor = NSColor.clearColor().CGColor
//        self.ui.updateButton.hidden = true
//    }
//    
//    func cellWasSelected() {
//        self.layer?.backgroundColor = NSColor.whiteColor().colorWithAlphaComponent(0.3).CGColor
//        self.ui.updateButton.hidden = false
//    }
//    
//    func cellWasHighlighted() {
//        self.layer?.backgroundColor = NSColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
//    }
    
    struct InterfaceElements {
        var cartfileTitleLabel = NSTextField()
        var updateButton = NSButton()
        var stackView = NSStackView()
        var allViewsWithinStackView: [NSView]
        var allViews: [NSView]
        
        init() {
            let allViewsWithinStackView: [NSView] = [self.cartfileTitleLabel, self.updateButton]
            self.allViewsWithinStackView = allViewsWithinStackView
            self.allViews = allViewsWithinStackView + [stackView]
            for view in self.allViews {
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
}


// MARK: Protocol Extensions

extension CartListTableCellView: Printable {
    override var description: String {
        return "CartListTableCellView \(self.ui.cartfileTitleLabel.stringValue):"
    }
}
