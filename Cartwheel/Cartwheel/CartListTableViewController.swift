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
final class CartListTableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var contentModel: CWCartfileDataSource!
    weak var parentWindowController: CartListWindowController?
    
    private let contentView = CartListView()
    private let MOVED_ROWS_TYPE = "MOVED_ROWS_TYPE"
    private let PUBLIC_TEXT_TYPES = [NSFilenamesPboardType]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add in my custom view
        self.view.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        
        // configure my view and add in the custom view
        self.contentView.configureViewWithController(self, tableViewDataSource: self, tableViewDelegate: self)
        
        // register for data source changes
        self.contentModel.cartfileObserver.add(self, self.dynamicType.modelDidChange)
        
        // configure the tableview for dragging
        self.contentView.registerTableViewForDraggedTypes([MOVED_ROWS_TYPE] + PUBLIC_TEXT_TYPES)
        
        // configure default cellHeight
        let rowHeight = self.tableView(nil, heightOfRow: self.contentModel.cartfiles.lastIndex())
        self.contentView.updateTableViewRowHeight(rowHeight)
        
        // register for notifications on window resize
        if let parentWindowController = self.parentWindowController {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeSize:", name: NSWindowDidEndLiveResizeNotification, object: parentWindowController.window)
        }
        
        // reload the data table
        self.contentView.reloadTableViewData()
    }
    
    // MARK: Data Source Observing
    
    func modelDidChange() {
        self.contentView.reloadTableViewData()
    }
    
    // MARK: Handle window resizing
    
    @objc private func windowDidChangeSize(notification: NSNotification) {
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
        view.viewDidLoad()
        view.setPrimaryTextFieldString("TestString")
        return view
    }()
    
    // Changed NSTableView to be optional because the method doesn't use it.
    // I call this method manually in windowDidLoad without passing in an TableView
    func tableView(tableView: NSTableView?, heightOfRow row: Int) -> CGFloat {
        if let cartfileURL = self.contentModel.cartfiles[safe: row],
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
        self.contentModel.cartfiles.count > 0 ? self.contentView.tableViewHasRows(true) : self.contentView.tableViewHasRows(false)
        
        // return the actual number of rows
        return self.contentModel.cartfiles.count
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView: CartListTableRowView
        if let recycledRowView = tableView.makeViewWithIdentifier(CartListTableRowView.identifier, owner: nil) as? CartListTableRowView {
            rowView = recycledRowView
        } else {
            rowView = CartListTableRowView()
        }
        rowView.configureRowViewIfNeededWithParentWindow(self.parentWindowController?.window)
        return rowView
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: CartListTableCellViewController
        if let recycledCellView = tableView.makeViewWithIdentifier(CartListTableCellViewController.identifier, owner: nil) as? CartListTableCellViewController {
            cellView = recycledCellView
        }
        else {
            cellView = CartListTableCellViewController()
        }
        cellView.configureViewIfNeeded()
        cellView.cartfileURL = self.contentModel.cartfiles[safe: row]
        return cellView
    }
    
    // MARK: Handle Dragging
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        pboard.declareTypes([MOVED_ROWS_TYPE] + PUBLIC_TEXT_TYPES, owner: self)
        pboard.writeObjects([CWIndexSetPasteboardContainer(indexSet: rowIndexes)])
        return true
    }
    
//    func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forRowIndexes rowIndexes: NSIndexSet) {
//        println("draggingSession: \(session) willBeginAtPoint: \(screenPoint) forRowIndexes: \(rowIndexes)")
//    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let activity = self.pasteboardActivity(info.draggingPasteboard())
        switch activity {
        case .DragFile(let url):
            if let draggedCartfiles = self.contentModel.cartfilesFromURL(url) {
                self.contentModel.addCartfiles(draggedCartfiles)
                return true
            } else {
                return false
            }
        case .MoveRow(let indexes):
            return true
        case .Unknown:
            return false
            
        }
    }

    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        let activity = self.pasteboardActivity(info.draggingPasteboard())
        switch activity {
        case .DragFile(let url):
            return NSDragOperation.Copy
        case .MoveRow(let indexes):
            return NSDragOperation.Move
        case .Unknown:
            return NSDragOperation.Generic
        }
    }
    
    private enum PasteboardActivity {
        case DragFile(url: NSURL)
        case MoveRow(indexSet: NSIndexSet)
        case Unknown
    }
    
    private func pasteboardActivity(pasteboard: NSPasteboard?) -> PasteboardActivity {
        if let pasteboard = pasteboard,
            let url = NSURL(fromPasteboard: pasteboard) {
                return .DragFile(url: url)
        } else if let pasteboard = pasteboard,
            let items = pasteboard.readObjectsForClasses([CWIndexSetPasteboardContainer.self], options: nil),
            let indexes = (items.first as? CWIndexSetPasteboardContainer)?.containedIndexSet {
                return .MoveRow(indexSet: indexes)
        } else {
            return .Unknown
        }
    }


    
    // MARK: Handle going away
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}