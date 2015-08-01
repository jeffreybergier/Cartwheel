//
//  CartListTableViewDelegate.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/31/15.
//  Copyright (c) 2015 Saturday Apps. All rights reserved.
//

import Cocoa
import ObserverSet

class CartListTableViewDelegate: NSObject, NSTableViewDelegate {
    
    weak var controller: CWCartfileDataSourceController?
    
    // MARK: Handle RowViews and CellViews
    
    weak var windowObserver: CartListWindowObserver?
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView: CartListTableRowView
        if let recycledRowView = tableView.makeViewWithIdentifier(CartListTableRowView.identifier, owner: nil) as? CartListTableRowView {
            rowView = recycledRowView
        } else {
            rowView = CartListTableRowView()
        }
        self.windowObserver?.windowMainStateObserver.add(rowView, rowView.dynamicType.parentWindowDidChangeMain)
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
        cellView.cartfile = self.controller?.contentModel.cartfiles[safe: row]
        return cellView
    }
    
    // MARK: Handle Cell Height
    
    private lazy var cellHeightCalculationView: CartListTableCellView = {
        let view = CartListTableCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.viewDidLoad()
        view.setPrimaryTextFieldString("TestString")
        return view
    }()
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cartfile = self.controller?.contentModel.cartfiles[safe: row] {
            self.cellHeightCalculationView.setPrimaryTextFieldString(cartfile.name)
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
    
    // MARK: Handle TableView Selection
    
    func tableViewSelectionDidChange(aNotification: NSNotification) {
        if let tableView = aNotification.object as? NSTableView {
            let ranges = tableView.selectedRowIndexes.ranges
            self.windowObserver?.tableViewRowSelectedStateObserver.notify(ranges)
        }
    }
}
