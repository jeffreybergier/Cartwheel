//
//  CartListTitlebarAccessoryView.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 6/7/15.
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

class CartListTitlebarAccessoryView: NSVisualEffectView {
    
    let ui = InterfaceElements()
    var viewConstraints = [NSLayoutConstraint]()
    weak var controller: CartListTitlebarAccessoryViewController?

    func viewDidLoad() {
        self.wantsLayer = true
        
        self.addSubview(self.ui.addButton)
        self.addSubview(self.ui.createNewButton)
        self.addSubview(self.ui.filterField)
        self.configure(addButton: self.ui.addButton)
        self.configure(createNewButton: self.ui.createNewButton)
        self.configure(filterField: self.ui.filterField)
        
        self.configureConstraints()
    }
    
    override func layout() {
        // configure the titlebar height
        
        self.ui.addButton.sizeToFit()
        let buttonHeight = self.ui.addButton.frame.height
        let totalHeight = 8 + buttonHeight
        self.superview!.frame.size.height = totalHeight
        
        super.layout()
    }
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        let filterFieldWidth = CGFloat(200)
        
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            // Constraints for Add Button
            self.ui.addButton.autoPinEdgeToSuperviewEdge(.Top , withInset: defaultInset)
            self.ui.addButton.autoPinEdgeToSuperviewEdge(.Leading , withInset: smallInset)
            
            // Constraints for the create new button
            self.ui.createNewButton.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultInset)
            self.ui.createNewButton.autoPinEdge(.Left, toEdge: .Right, ofView: self.ui.addButton, withOffset: defaultInset)
            
            // constraints for FilterField
            self.ui.filterField.autoPinEdgeToSuperviewEdge(.Trailing, withInset: smallInset)
            self.ui.filterField.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultInset)
            self.ui.filterField.autoMatchDimension(.Width, toDimension: .Width, ofView: self.ui.filterField.superview, withMultiplier: 0.4)
            self.ui.filterField.autoPinEdge(.Left, toEdge: .Right, ofView: self.ui.createNewButton, withOffset: defaultInset, relation: NSLayoutRelation.GreaterThanOrEqual)
        }
        
        let optionalPureLayoutConstraints = pureLayoutConstraints.map { (object) -> NSLayoutConstraint? in
            if let constraint = object as? NSLayoutConstraint {
                return constraint
            } else {
                return nil
            }
        }
        
        self.viewConstraints += Array.filterOptionals(optionalPureLayoutConstraints)
        self.addConstraints(self.viewConstraints)
    }
    
    private func configure(#addButton: NSButton) {
        if let _ = addButton.superview {
            addButton.setButtonType(.MomentaryPushInButton)
            addButton.bezelStyle = .RoundedBezelStyle
            addButton.title = NSLocalizedString("Add Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
            addButton.target = self.controller
            addButton.action = "didClickAddCartFileButton:"
        } else {
            fatalError("CartListView: Tried to configure the AddButton before it was in the view hierarchy.")
        }
    }
    
    private func configure(#createNewButton: NSButton) {
        if let _ = createNewButton.superview {
            createNewButton.setButtonType(.MomentaryPushInButton)
            createNewButton.bezelStyle = .RoundedBezelStyle
            createNewButton.title = NSLocalizedString("Create Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
            createNewButton.target = self.controller
            createNewButton.action = "didClickCreateNewCartFileButton:"
        } else {
            fatalError("CartListView: Tried to configure the AddButton before it was in the view hierarchy.")
        }
    }
    
    private func configure(#filterField: NSSearchField) {
        if let _ = self.ui.filterField.superview {
            self.ui.filterField.delegate = self.controller
        } else {
            fatalError("CartListView: Tried to configure the filterField before it was in the view hierarchy.")
        }
    }
    
    struct InterfaceElements {
        var addButton = NSButton()
        var createNewButton = NSButton()
        var filterField = NSSearchField()
    }
}
