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

final class CartListView: NSView {
    
    // MARK: UI Element
    
    let addButton = CWEventPassingButton(roundedBezelStyle: true)
    let deleteButton = NSButton(roundedBezelStyle: true)
    let tableView = NSTableView()
    let scrollView = NSScrollView()
    private let tableColumn = NSTableColumn(identifier: "CartListColumn")
    
    // MARK: Handle Initialization
    
    private var viewConstraints = [NSLayoutConstraint]()
    
    func configureViewWithController(controller: NSViewController?, tableViewDataSource: NSTableViewDataSource?, tableViewDelegate: NSTableViewDelegate?) {
        self.wantsLayer = true
        
        self.addSubview(self.scrollView)
        self.addSubview(self.addButton)
        self.addSubview(self.deleteButton)
        
        self.configure(tableView: self.tableView, scrollView: self.scrollView, tableColumn: self.tableColumn)
        self.configure(addButton: self.addButton, deleteButton: self.deleteButton, withController: controller)
        
        self.tableView.setDelegate(tableViewDelegate)
        self.tableView.setDataSource(tableViewDataSource)
        
        self.configureConstraints()
    }
    
    // MARK: Helper Methods
    
    func noteHeightOfVisibleRowsChanged() {
        let visibleRows = self.tableView.rowsInRect(self.tableView.visibleRect)
        self.tableView.noteHeightOfRowsWithIndexesChanged(NSIndexSet(indexesInRange: visibleRows))
    }
    
    // MARK: Handle Configuring The SubViews
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let defaultSmallSquareButtonSize = CGFloat(30)
        let smallInset = round(defaultInset / 1.5)
        let filterFieldWidth = CGFloat(200)
        
        let constraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.scrollView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
            
            self.addButton.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
            self.addButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultInset)
            self.deleteButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultInset)
            
            self.deleteButton.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.addButton, withOffset: defaultInset)
            self.deleteButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset, relation: .GreaterThanOrEqual)
            
            self.addButton.autoSetDimensionsToSize(CGSize(width: defaultSmallSquareButtonSize, height: defaultSmallSquareButtonSize - 6))
            self.deleteButton.autoSetDimensionsToSize(CGSize(width: defaultSmallSquareButtonSize, height: defaultSmallSquareButtonSize - 6))
        }
        
        let pureLayoutConstraints = Array.filterOptionals(constraints.map({ object -> NSLayoutConstraint? in
            if let constraint = object as? NSLayoutConstraint { return constraint } else { return .None }
        }))
        
        self.viewConstraints += pureLayoutConstraints
        self.addConstraints(self.viewConstraints)
    }
    
    func configure(#tableView: NSTableView, scrollView: NSScrollView, tableColumn: NSTableColumn) {
        tableView.addTableColumn(self.tableColumn)
        scrollView.documentView = self.tableView
        scrollView.hasVerticalScroller = true
        tableView.headerView = nil
        tableView.selectionHighlightStyle = .None
        tableView.draggingDestinationFeedbackStyle = .Gap
        tableView.rowSizeStyle = .Custom
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = NSColor.clearColor()
        tableView.gridStyleMask = .SolidHorizontalGridLineMask
        scrollView.drawsBackground = false
    }
    
    func configure(#addButton: NSButton, deleteButton: NSButton, withController controller: NSViewController?) {
        let font = NSFont.systemFontOfSize(20)
        addButton.font = font
        deleteButton.font = font
        addButton.title = "+"
        deleteButton.title = "–"
        
        addButton.target = controller
        deleteButton.target = controller
        
        addButton.action = "didClickAddButton:"
        deleteButton.action = "didClickDeleteButton:"
        
        deleteButton.enabled = false
    }
}
