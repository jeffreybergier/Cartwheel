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

class CartListWindowController: NSWindowController {
    
    var contentView = CartListView()
    private let dataSource = CWCartfileDataSource.sharedInstance
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let titlebarAccessoryViewController = CartListTitlebarAccessoryViewController()
        titlebarAccessoryViewController.window = self.window
        titlebarAccessoryViewController.mainViewController = self
        
        self.window?.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
        self.window?.minSize = NSSize(width: 380, height: 500)
        self.window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)!
        self.window?.addTitlebarAccessoryViewController(titlebarAccessoryViewController)
        self.window?.styleMask = self.window!.styleMask | NSFullSizeContentViewWindowMask
        self.window?.title = NSLocalizedString("Cartwheel", comment: "Cartwheel name for window title")
        
        // configure my view and add in the custom view
        self.window!.contentView = self.contentView
        
        // configure the main view
        self.contentView.controller = self
        self.contentView.viewDidLoad()
        
        // register for notifications on window resize
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeSize:", name: NSWindowDidEndLiveResizeNotification, object: self.window)
        
        // set the delegate on the tableview
        self.contentView.ui.tableView.registerNib(NSNib(nibNamed: "CartListTableCellViewController", bundle: nil)!, forIdentifier: "CartListTableCellViewController")
        self.contentView.ui.tableView.registerNib(NSNib(nibNamed: "CartListTableRowView", bundle: nil)!, forIdentifier: "CartListTableRowView") // it seems basically impossible to use a custom cell not based on a nib. The NIB is blank and will continue to be blank.
        self.contentView.ui.tableView.setDataSource(self)
        self.contentView.ui.tableView.setDelegate(self)
        self.contentView.ui.tableView.reloadData()
    }
    
    func window(window: NSWindow, didDecodeRestorableState state: NSCoder) {
        // call reload table data here because this happens after window geometry is set
        // this reduces errors for autolayout and makes it so the cell width is known when calculating height
        let visibleRows = self.contentView.ui.tableView.rowsInRect(self.contentView.ui.tableView.visibleRect)
        self.contentView.ui.tableView.noteHeightOfRowsWithIndexesChanged(NSIndexSet(indexesInRange: visibleRows))
    }
    
    @objc private func windowDidChangeSize(notification: NSNotification) {
        let visibleRows = self.contentView.ui.tableView.rowsInRect(self.contentView.ui.tableView.visibleRect)
        self.contentView.ui.tableView.noteHeightOfRowsWithIndexesChanged(NSIndexSet(indexesInRange: visibleRows))
    }
    
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
        view.ui.cartfileTitleLabel.stringValue = "TestString"
        return view
    }()
}

extension CartListWindowController: NSTableViewDelegate {
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cartfileURL = self.dataSource.cartfiles[safe: row],
            let pathComponents = cartfileURL.pathComponents,
            let containingFolder = pathComponents[pathComponents.count - 2] as? String {
                self.cellHeightCalculationView.ui.cartfileTitleLabel.stringValue = containingFolder
        } else {
            self.cellHeightCalculationView.clearCellView()
        }
        self.cellHeightCalculationView.needsLayout = true
        self.cellHeightCalculationView.layoutSubtreeIfNeeded()
        
        let defaultInset = CGFloat(8.0)
        let smallInset = round(defaultInset / 1.5)
        let viewHeight = self.cellHeightCalculationView.ui.stackView.frame.size.height
        let cellHeight = (smallInset * 2) + viewHeight + 1 // the +1 fixes issues in the view debugger
        
        return cellHeight
    }
}

// MARK: NSTableViewDataSource

extension CartListWindowController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.dataSource.cartfiles.count
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
