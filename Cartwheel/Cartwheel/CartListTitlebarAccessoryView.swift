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
        
        self.addSubview(self.ui.stackView)
        self.configure(stackView: self.ui.stackView, withViews: self.ui.allViewsWithinStackView)
        self.configure(addButton: self.ui.addButton)
        self.configure(createNewButton: self.ui.createNewButton)
        self.configure(filterField: self.ui.filterField)
        
        self.configureConstraints()
    }
    
    override func layout() {
        // configure the titlebar height
//        let buttonHeight = self.ui.stackView.frame.height
//        let totalHeight = 8 + buttonHeight
//        self.superview!.frame.size.height = totalHeight
        
        super.layout()
    }
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        let filterFieldWidth = CGFloat(200)
        
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.ui.stackView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsets(top: 0, left: defaultInset, bottom: 0, right: defaultInset))
        }
        
        let optionalPureLayoutConstraints = pureLayoutConstraints.map { (optionalConstraint) -> NSLayoutConstraint? in
            if let constraint = optionalConstraint as? NSLayoutConstraint {
                return constraint
            } else {
                return nil
            }
        }
        
        for constraint in optionalPureLayoutConstraints {
            constraint?.priority = 1000
        }
        
        self.viewConstraints += Array.filterOptionals(optionalPureLayoutConstraints)
        self.addConstraints(self.viewConstraints)
    }
    
    private func configure(#addButton: NSButton) {
        if let _ = addButton.superview {
            addButton.setContentCompressionResistancePriority(1000, forOrientation: .Vertical)
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
        if let _ = filterField.superview {
            filterField.delegate = self.controller
        } else {
            fatalError("CartListView: Tried to configure the filterField before it was in the view hierarchy.")
        }
    }
    
    private func configure(#stackView: NSStackView, withViews views: [NSView]) {
        if let _ = stackView.superview {
            stackView.orientation = .Horizontal
            stackView.setContentHuggingPriority(1000, forOrientation: .Vertical)
            for view in views {
                stackView.addView(view, inGravity: .Top)
            }
        } else {
            fatalError("CartListView: Tried to configure the filterField before it was in the view hierarchy.")
        }
    }
    
    struct InterfaceElements {
        var addButton = NSButton()
        var createNewButton = NSButton()
        var filterField = NSSearchField()
        var stackView = NSStackView()
        var allViewsWithinStackView: [NSView]
        var allViews: [NSView]
        
        init() {
            let allViewsWithinStackView: [NSView] = [self.addButton, self.createNewButton, self.filterField]
            self.allViewsWithinStackView = allViewsWithinStackView
            self.allViews = allViewsWithinStackView + [stackView]
            for view in self.allViews {
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }

}
