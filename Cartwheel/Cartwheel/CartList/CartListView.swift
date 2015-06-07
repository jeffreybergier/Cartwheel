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

class CartListView: NSVisualEffectView {
    
    let ui = InterfaceElements()
    var viewConstraints = [NSLayoutConstraint]()
    weak var controller: CartListViewController?
    
    func viewDidLoad() {
        self.wantsLayer = true
        
        self.addSubview(self.ui.scrollView)
        self.configure(tableView: self.ui.tableView, scrollView: self.ui.scrollView, tableColumn: self.ui.tableColumn)
        
        self.configureConstraints()
    }
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        let filterFieldWidth = CGFloat(200)
        
        let pureLayoutConstraints = NSView.autoCreateConstraintsWithoutInstalling() {
            // Constraints for table
            self.ui.scrollView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
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
    
    func configure(#tableView: NSTableView, scrollView: NSScrollView, tableColumn: NSTableColumn) {
        if let _ = scrollView.superview {
            tableView.addTableColumn(self.ui.tableColumn)
            tableView.registerNib(NSNib(nibNamed: "CartListTableCellViewController", bundle: nil)!, forIdentifier: "CartListTableCellViewController") // it seems basically impossible to use a custom cell not based on a nib. The NIB is blank and will continue to be blank.
            scrollView.documentView = self.ui.tableView
            scrollView.hasVerticalScroller = true
            tableColumn.width = self.ui.scrollView.frame.width
            tableView.headerView = nil
            tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
            tableView.backgroundColor = NSColor.clearColor()
            scrollView.drawsBackground = false
        } else {
            fatalError("CartListView: Tried to configure the TableView before it was in the view hierarchy.")
        }
    }
    
    struct InterfaceElements {
        var scrollView: NSScrollView = NSScrollView()
        var tableView: NSTableView = NSTableView()
        var tableColumn: NSTableColumn = NSTableColumn(identifier: "CartListColumn")
    }
}
