//
//  CartListTableViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/2/15.
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

@objc(CartListTableViewController)
class CartListTableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    weak var parentWindowController: NSWindowController?
    
    private let contentView = CartListView()
    private let dataSource = CWCartfileDataSource.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add in my custom view
        self.view.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        
        // Register Blank nibs so Cell Reuse Works
        self.contentView.registerTableViewNIB("CartListTableCellViewController")
        self.contentView.registerTableViewNIB("CartListTableRowView")
        
        // configure my view and add in the custom view
        self.contentView.configureViewWithController(self, tableViewDataSource: self, tableViewDelegate: self)
        
        // configure default cellHeight
        let rowHeight = self.tableView(nil, heightOfRow: self.dataSource.cartfiles.lastIndex())
        self.contentView.updateTableViewRowHeight(rowHeight)
        
        // register for notifications on window resize
        if let parentWindowController = self.parentWindowController {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeSize:", name: NSWindowDidEndLiveResizeNotification, object: parentWindowController.window)
        }
    }
    
    private var viewDidAppearOnce = false
    override func viewDidAppear() {
        super.viewDidAppear()
        if self.viewDidAppearOnce == false {
            self.viewDidAppearOnce = true
            self.contentView.reloadTableViewData()
        }
    }
    
    // MARK: Handle window resizing
    
    @objc private func windowDidChangeSize(notification: NSNotification) {
        self.contentView.noteHeightOfVisibleRowsChanged()
        self.contentView.setTableViewEdgeInsets(NSEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
    }
    
    // MARK: NSTableViewDelegate
    
    private lazy var cellHeightCalculationView: CartListTableCellView = {
        // this cell is used to let the table calculate the height of each cell dynamically based on the content
        // the top of the cell is locked to the bottom of the window
        let view = CartListTableCellView()
        let defaultInset = CGFloat(8.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(view)
        view.hidden = true
        view.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.contentView, withOffset: 0)
        view.autoPinEdgeToSuperviewEdge(.Leading, withInset: defaultInset)
        view.autoPinEdgeToSuperviewEdge(.Trailing, withInset: defaultInset)
        view.autoSetDimension(.Height, toSize: 100)
        view.viewDidLoad()
        view.setPrimaryTextFieldString("TestString")
        return view
    }()
    
    // Changed NSTableView to be optional because the method doesn't use it.
    // I call this method manually in windowDidLoad without passing in an TableView
    func tableView(tableView: NSTableView?, heightOfRow row: Int) -> CGFloat {
        if let cartfileURL = self.dataSource.cartfiles[safe: row],
            let pathComponents = cartfileURL.pathComponents,
            let containingFolder = pathComponents[pathComponents.count - 2] as? String {
                self.cellHeightCalculationView.setPrimaryTextFieldString(containingFolder)
        } else {
            self.cellHeightCalculationView.clearCellContents()
        }
        self.cellHeightCalculationView.needsLayout = true
        self.cellHeightCalculationView.layoutSubtreeIfNeeded()
        
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        let viewHeight = self.cellHeightCalculationView.viewHeightForTableRowHeightCalculation
        let cellHeight = (smallInset * 2) + viewHeight + 1 // the +1 fixes issues in the view debugger
        
        return cellHeight
    }
    
    // MARK: NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        // this line tells the tableview to add / remove gridlines when the table is full / empty
        self.dataSource.cartfiles.count > 0 ? self.contentView.tableViewHasRows(true) : self.contentView.tableViewHasRows(false)
        
        // this line returns 0 if the window has not yet appeared on screen.
        // this avoids autolayout warning issues.
        return self.viewDidAppearOnce ? self.dataSource.cartfiles.count : 0
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = tableView.makeViewWithIdentifier("CartListTableRowView", owner: nil) as? CartListTableRowView
        return rowView
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Create and configure CellView
        let cellView = tableView.makeViewWithIdentifier("CartListTableCellViewController", owner: nil) as? CartListTableCellViewController
        cellView?.cartfileURL = self.dataSource.cartfiles[safe: row]
        
        // Retrieve RowView and give it a reference to the CellView
        let rowView = tableView.rowViewAtRow(row, makeIfNecessary: false) as? CartListTableRowView
        rowView!.cellViewController = cellView
        return cellView
    }
}