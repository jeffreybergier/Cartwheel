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
    weak var controller: CartListViewController?
        
    func viewDidLoad() {
        NSLog("CartListView Did Load")
        self.wantsLayer = true
        
        self.addSubview(self.ui.scrollView)
        self.ui.configureTableView()
        }
    
    struct InterfaceElements {
        // MARK: TableView
        var scrollView: NSScrollView = NSScrollView()
        var tableView: NSTableView = NSTableView()
        var tableColumn: NSTableColumn = NSTableColumn(identifier: "CartListColumn")
        
        func configureTableView() {
            if self.scrollView.superview != nil {
                self.scrollView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
                
                self.tableView.addTableColumn(self.tableColumn)
                self.tableView.registerNib(NSNib(nibNamed: "CartListTableCellViewController", bundle: nil)!, forIdentifier: "CartListTableCellViewController") // it seems basically impossible to use a custom cell not based on a nib. The NIB is blank and will continue to be blank.
                self.scrollView.documentView = self.tableView
                self.scrollView.hasVerticalScroller = true
                self.scrollView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
                self.tableColumn.width = self.scrollView.frame.width

            } else {
                fatalError("CartListView: Tried to configure the TableView before it was in the view hierarchy.")
            }
        }
        
        // MARK: Edit Button
        var editButton = NSButton()
    }
    
}
