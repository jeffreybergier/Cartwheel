//
//  CartListView.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/27/15.
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

class CartListView: NSView {
    
    let ui = InterfaceElements()
    var viewConstraints = [NSLayoutConstraint]()
    weak var controller: CartListViewController?
    
    func viewDidLoad() {
        NSLog("CartListView Did Load")
        self.wantsLayer = true
        
        self.addSubview(self.ui.scrollView)
        self.addSubview(self.ui.addButton)
        self.addSubview(self.ui.filterField)
        self.configureTableView()
        self.configureAddButton()
        self.configureFilterField()
        
        self.configureConstraints()
    }
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        let filterFieldWidth = CGFloat(200)
        
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            // Constraints for Add Button
            self.ui.addButton.autoPinEdgeToSuperviewEdge(.Top , withInset: defaultInset)
            self.ui.addButton.autoPinEdgeToSuperviewEdge(.Leading , withInset: smallInset)
            
            // constraints for FilterField
            self.ui.filterField.autoPinEdgeToSuperviewEdge(.Trailing, withInset: smallInset)
            self.ui.filterField.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultInset)
            self.ui.filterField.autoSetDimension(.Width, toSize: filterFieldWidth)

            // Constraints for table
            self.ui.scrollView.autoPinEdgeToSuperviewEdge(.Leading , withInset: 0)
            self.ui.scrollView.autoPinEdgeToSuperviewEdge(.Trailing , withInset: 0)
            self.ui.scrollView.autoPinEdgeToSuperviewEdge(.Bottom , withInset: 0)
            
            // Constraints for Interacting Elements
            self.ui.scrollView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.ui.addButton, withOffset: defaultInset)
        }
        
        let optionalPureLayoutConstraints = pureLayoutConstraints.map { (object) -> NSLayoutConstraint? in
            if let constraint = object as? NSLayoutConstraint {
                return constraint
            } else {
                return nil
            }
        }
        
        let manualConstraints: [NSLayoutConstraint] = {
            let constraintBetweenAddButtonAndFilterField = NSLayoutConstraint(item: self.ui.filterField,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                toItem: self.ui.addButton,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1.0,
                constant: defaultInset)
            
            return [constraintBetweenAddButtonAndFilterField]
        }()
        
        self.viewConstraints += Array.filterOptionals(optionalPureLayoutConstraints)
        self.viewConstraints += manualConstraints
        self.addConstraints(self.viewConstraints)
    }
    
    private func configureAddButton() {
        if self.ui.addButton.superview != nil {
            self.ui.addButton.setButtonType(.MomentaryPushInButton)
            self.ui.addButton.bezelStyle = .RoundedBezelStyle
            self.ui.addButton.title = NSLocalizedString("+ Add Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
            self.ui.addButton.target = self.controller
            self.ui.addButton.action = "didClickAddCartFileButton:"
        } else {
            fatalError("CartListView: Tried to configure the AddButton before it was in the view hierarchy.")
        }
    }
    
    private func configureFilterField() {
        if self.ui.filterField.superview != nil {
            self.ui.filterField.delegate = self.controller
            self.ui.filterField.becomeFirstResponder()
        } else {
            fatalError("CartListView: Tried to configure the filterField before it was in the view hierarchy.")
        }
    }
    
    func configureTableView() {
        if self.ui.scrollView.superview != nil {
            self.ui.tableView.addTableColumn(self.ui.tableColumn)
            self.ui.tableView.registerNib(NSNib(nibNamed: "CartListTableCellViewController", bundle: nil)!, forIdentifier: "CartListTableCellViewController") // it seems basically impossible to use a custom cell not based on a nib. The NIB is blank and will continue to be blank.
            self.ui.scrollView.documentView = self.ui.tableView
            self.ui.scrollView.hasVerticalScroller = true
            self.ui.tableColumn.width = self.ui.scrollView.frame.width
            self.ui.tableView.headerView = nil
        } else {
            fatalError("CartListView: Tried to configure the TableView before it was in the view hierarchy.")
        }
    }
    
    struct InterfaceElements {
        var scrollView: NSScrollView = NSScrollView()
        var tableView: NSTableView = NSTableView()
        var tableColumn: NSTableColumn = NSTableColumn(identifier: "CartListColumn")
        var addButton = NSButton()
        var filterField = NSSearchField()
    }
}
