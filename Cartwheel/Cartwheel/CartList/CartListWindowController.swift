//
//  CartListWindowController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/28/15.
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

class CartListWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    
    // MARK: Handle Initialization
    
    var contentView = CartListView()
    private let dataSource = CWCartfileDataSource.sharedInstance
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // configure titlebar view controller
        let titlebarAccessoryViewController = CartListTitlebarAccessoryViewController()
        titlebarAccessoryViewController.window = self.window
        titlebarAccessoryViewController.mainViewController = self
        
        // configure the window
        self.window?.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
        self.window?.minSize = NSSize(width: 380, height: 500)
        self.window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)!
        self.window?.addTitlebarAccessoryViewController(titlebarAccessoryViewController)
        self.window?.styleMask = self.window!.styleMask | NSFullSizeContentViewWindowMask
        self.window?.title = NSLocalizedString("Cartwheel", comment: "Cartwheel name for window title")
        
        // Register Blank nibs so Cell Reuse Works
        self.contentView.registerTableViewNIB("CartListTableCellViewController")
        self.contentView.registerTableViewNIB("CartListTableRowView")
        
        // configure my view and add in the custom view
        self.window?.contentView = self.contentView
        self.contentView.configureViewWithController(self)
        
        // register for notifications on window resize
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeSize:", name: NSWindowDidEndLiveResizeNotification, object: self.window)
        
        // this notification is used to know when the window appears on screen
        // this is needed to avoid autolayout warnings with the table
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidBecomeMain:", name: NSWindowDidBecomeMainNotification, object: self.window)
    }
    
    // MARK: Autolayout Hack
    // this code makes it so the table does not try to layout cells until it appears on screen
    private var windowDidAppearOnce = false
    @objc private func windowDidBecomeMain(notification: NSNotification) {
        if self.windowDidAppearOnce == false {
            self.windowDidAppearOnce = true
            self.contentView.reloadTableViewData()
        }
        println("window did become main")
    }
    
    // MARK: Handle window resizing
    
    @objc private func windowDidChangeSize(notification: NSNotification) {
        self.contentView.noteHeightOfVisibleRowsChanged()
    }
    
    // MARK: Handle Restoring from Previous State
    
    func window(window: NSWindow, didDecodeRestorableState state: NSCoder) {
        self.contentView.noteHeightOfVisibleRowsChanged()
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
        view.viewDidLoadWithController(nil)
        view.populatePrimaryTextFieldWithString("TestString")
        return view
    }()
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cartfileURL = self.dataSource.cartfiles[safe: row],
            let pathComponents = cartfileURL.pathComponents,
            let containingFolder = pathComponents[pathComponents.count - 2] as? String {
                self.cellHeightCalculationView.populatePrimaryTextFieldWithString(containingFolder)
        } else {
            self.cellHeightCalculationView.clearContents()
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
        return self.windowDidAppearOnce ? self.dataSource.cartfiles.count : 0
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = tableView.makeViewWithIdentifier("CartListTableRowView", owner: nil) as? CartListTableRowView
        rowView?.isLastRow = row < self.dataSource.cartfiles.count - 1 ? false : true
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