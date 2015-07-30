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
    
    // MARK: Handle Initialization
    
    private let ui = InterfaceElements()
    private var viewConstraints = [NSLayoutConstraint]()
    
    func configureViewWithController(controller: NSViewController?, tableViewDataSource: NSTableViewDataSource?, tableViewDelegate: NSTableViewDelegate?) {
        self.wantsLayer = true
        
        self.addSubview(self.ui.scrollView)
        self.addSubview(self.ui.addButton)
        self.addSubview(self.ui.deleteButton)
        
        self.configure(tableView: self.ui.tableView, scrollView: self.ui.scrollView, tableColumn: self.ui.tableColumn)
        self.configure(addButton: self.ui.addButton, deleteButton: self.ui.deleteButton, withController: controller)
        
        self.ui.tableView.setDelegate(tableViewDelegate)
        self.ui.tableView.setDataSource(tableViewDataSource)
        
        self.configureConstraints()
    }
    
    // MARK: Handle External TableView
    
    func updateTableViewRowHeight(newHeight: CGFloat) {
        self.ui.tableView.rowHeight = newHeight
    }
    
    func tableViewHasRows(hasRows: Bool) {
        self.ui.tableView.gridStyleMask = hasRows ? .SolidHorizontalGridLineMask : .GridNone
    }
    
    func reloadTableViewData() {
        self.ui.tableView.reloadData()
    }
    
    func registerTableViewNIB(nibName: String) {
        self.ui.tableView.registerNib(NSNib(nibNamed: nibName, bundle: nil)!, forIdentifier: nibName)
    }
    
    func noteHeightOfVisibleRowsChanged() {
        let visibleRows = self.ui.tableView.rowsInRect(self.ui.tableView.visibleRect)
        self.ui.tableView.noteHeightOfRowsWithIndexesChanged(NSIndexSet(indexesInRange: visibleRows))
    }
    
    func registerTableViewForDraggedTypes(draggedTypes: [AnyObject]) {
        self.ui.tableView.registerForDraggedTypes(draggedTypes)
    }
    
    var tableViewSelectedRowIndexes: [Range<Int>] {
        return self.ui.tableView.selectedRowIndexes.ranges
    }
    
    // MARK: Handle Configuring The SubViews
    
    private func configureConstraints() {
        let defaultInset = CGFloat(8.0)
        let defaultSmallSquareButtonSize = CGFloat(30)
        let smallInset = round(defaultInset / 1.5)
        let filterFieldWidth = CGFloat(200)
        
        let constraints = NSView.autoCreateConstraintsWithoutInstalling() {
            self.ui.scrollView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
            
            self.ui.addButton.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
            self.ui.addButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultInset)
            self.ui.deleteButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultInset)
            
            self.ui.deleteButton.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.ui.addButton, withOffset: defaultInset)
            self.ui.deleteButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset, relation: .GreaterThanOrEqual)
            
            self.ui.addButton.autoSetDimensionsToSize(CGSize(width: defaultSmallSquareButtonSize, height: defaultSmallSquareButtonSize))
            self.ui.deleteButton.autoSetDimensionsToSize(CGSize(width: defaultSmallSquareButtonSize, height: defaultSmallSquareButtonSize))
        }
        
        let pureLayoutConstraints = Array.filterOptionals(constraints.map({ object -> NSLayoutConstraint? in
            if let constraint = object as? NSLayoutConstraint { return constraint } else { return .None }
        }))
        
        self.viewConstraints += pureLayoutConstraints
        self.addConstraints(self.viewConstraints)
    }
    
    func configure(#tableView: NSTableView, scrollView: NSScrollView, tableColumn: NSTableColumn) {
        tableView.addTableColumn(self.ui.tableColumn)
        scrollView.documentView = self.ui.tableView
        scrollView.hasVerticalScroller = true
        tableView.headerView = nil
        tableView.selectionHighlightStyle = .None
        tableView.draggingDestinationFeedbackStyle = .Gap
        tableView.rowSizeStyle = .Custom
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = NSColor.clearColor()
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
    }
    
    struct InterfaceElements {
        var addButton = NSButton.buttonWithDefaultStyle()
        var deleteButton = NSButton.buttonWithDefaultStyle()
        var scrollView = NSScrollView()
        var tableView = NSTableView()
        var tableColumn = NSTableColumn(identifier: "CartListColumn")
    }
}
