//
//  CartListTableView.swift
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

class CartListTableViewContainer: NSView {
    
    let scrollView: NSScrollView = NSScrollView()
    let tableView: NSTableView = NSTableView()
    let tableColumn: NSTableColumn = NSTableColumn(identifier: "CartListColumn")
    
    override init() {
        super.init()
        
        self.commonInitializer()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.commonInitializer()
    }
    
    private func commonInitializer() {
        self.tableView.addTableColumn(self.tableColumn)
        self.tableView.registerNib(NSNib(nibNamed: "CartListTableCellViewController", bundle: nil)!, forIdentifier: "CartListTableCellViewController") // it seems basically impossible to use a custom cell not based on a nib. The NIB is blank and will continue to be blank.
        self.scrollView.documentView = self.tableView
        self.scrollView.hasVerticalScroller = true
        self.addSubview(self.scrollView)
        self.scrollView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        self.tableColumn.width = self.scrollView.frame.width
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
