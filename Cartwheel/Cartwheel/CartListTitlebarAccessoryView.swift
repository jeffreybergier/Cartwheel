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

final class CartListTitlebarAccessoryView: NSView {
    
    // MARK: Handle Intialization
    
    private let ui = InterfaceElements()
    private var viewConstraints = [NSLayoutConstraint]()

    func viewDidLoadWithController(controller: NSViewController?) {
        self.wantsLayer = true
        
        self.addSubview(self.ui.stackView)
        self.configureStackView(self.ui.stackView, withViews: self.ui.allViewsWithinStackView)
        self.configureConstraints()
    }
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        let filterFieldMaxWidth = CGFloat(400)
        let filterFieldWidth = CGFloat(200)
        
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Top, withInset: smallInset)
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
            self.ui.stackView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset)
            
            NSView.autoSetPriority(CWLayoutPriority.DefaultLow, forConstraints: {
                self.ui.searchField.autoSetDimension(.Width, toSize: filterFieldMaxWidth, relation: .LessThanOrEqual)
            })
        }
        
        let optionalPureLayoutConstraints = pureLayoutConstraints.map { (optionalConstraint) -> NSLayoutConstraint? in
            if let constraint = optionalConstraint as? NSLayoutConstraint {
                return constraint
            } else {
                return nil
            }
        }
        
        self.viewConstraints = Array.filterOptionals(optionalPureLayoutConstraints)
        self.addConstraints(self.viewConstraints)
    }
    
    // MARK: Handle Sizing Vertical View Based on Autolayout
    
    override func layout() {
        // configure the titlebar height
        let stackViewHeight = self.ui.stackView.frame.height
        let totalHeight = 12 + stackViewHeight
        self.superview?.frame.size.height = totalHeight
        
        super.layout()
    }
    
    // MARK: Public Interface for the Controller
    
    func setSearchFieldDelegate(delegate: NSTextFieldDelegate) {
        self.ui.searchField.delegate = delegate
    }
    
    func setLeftButtonTitle(newTitle: String) {
        self.ui.leftButton.title = newTitle
    }
    
    func setMiddleButtonTitle(newTitle: String) {
        self.ui.middleButton.title = newTitle
    }
    
    func setLeftButtonAction(action: Selector, forTarget target: NSObject) {
        self.ui.leftButton.target = target
        self.ui.leftButton.action = action
    }
    
    func setMiddleButtonAction(action: Selector, forTarget target: NSObject) {
        self.ui.middleButton.target = target
        self.ui.middleButton.action = action
    }
    
    // MARK: Configure Subviews
    
    private func configureStackView(stackView: NSStackView, withViews views: [NSView]) {
        stackView.orientation = .Horizontal
        for view in views {
            if let view = view as? NSSearchField {
                stackView.addView(view, inGravity: .Bottom)
            } else {
                stackView.addView(view, inGravity: .Top)
            }
        }
    }
    
    struct InterfaceElements {
        var leftButton = NSButton.buttonWithDefaultStyle()
        var middleButton = NSButton.buttonWithDefaultStyle()
        var searchField = NSSearchField()
        var stackView = NSStackView()
        var allViewsWithinStackView: [NSView]
        var allViews: [NSView]
        
        init() {
            let allViewsWithinStackView: [NSView] = [self.leftButton, self.middleButton, self.searchField]
            self.allViewsWithinStackView = allViewsWithinStackView
            self.allViews = allViewsWithinStackView + [stackView]
            for view in self.allViews {
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }

}
