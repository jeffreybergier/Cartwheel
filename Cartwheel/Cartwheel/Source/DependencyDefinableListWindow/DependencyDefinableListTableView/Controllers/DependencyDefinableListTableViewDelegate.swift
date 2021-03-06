//
//  CartListTableViewDelegate.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/31/15.
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
import ObserverSet
import XCGLogger

class DependencyDefinableListTableViewDelegate: DependencyDefinableListChildController, NSTableViewDelegate {
    
    private let cartfileUpdaterManager = CartfileUpdaterManager()
    private let log = XCGLogger.defaultInstance()
    
    // MARK: Handle RowViews and CellViews
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView: DependencyDefinableListTableRowView
        if let recycledRowView = tableView.makeViewWithIdentifier(DependencyDefinableListTableRowView.identifier, owner: nil) as? DependencyDefinableListTableRowView {
            rowView = recycledRowView
        } else {
            rowView = DependencyDefinableListTableRowView()
        }
        if rowView.configuredOnce == false {
            self.windowObserver?.tableViewRowIsDraggingObserver.add(rowView, rowView.dynamicType.tableDraggingStateChanged)
            rowView.configuredOnce = true
        }
        return rowView
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cartfile = self.controller?.dependencyDefinables?[safe: row] as? Cartfile {
            let cellView: CartfileTableCellView
            if let recycledCellView = tableView.makeViewWithIdentifier(CartfileTableCellView.identifier, owner: nil) as? CartfileTableCellView {
                cellView = recycledCellView
            }
            else {
                cellView = CartfileTableCellView()
            }
            
            let controller: CartfileTableCellViewController
            if let existingController = cellView.controller {
                controller = existingController
            } else {
                controller = CartfileTableCellViewController()
                cellView.controller = controller
                controller.view = cellView
            }
            
            controller.configureViewWithWindow(self.controller!.window!, updateController: self.cartfileUpdaterManager)
            controller.cartfile = cartfile
            
            return cellView
        } else if let podfile = self.controller?.dependencyDefinables?[safe: row] as? Podfile {
            let cellView: PodfileTableCellView
            if let recycledCellView = tableView.makeViewWithIdentifier(PodfileTableCellView.identifier, owner: nil) as? PodfileTableCellView {
                cellView = recycledCellView
            }
            else {
                cellView = PodfileTableCellView()
            }
            
            let controller: PodfileTableCellViewController
            if let existingController = cellView.controller {
                controller = existingController
            } else {
                controller = PodfileTableCellViewController()
                cellView.controller = controller
                controller.view = cellView
            }
            
            controller.configureViewWithWindow(self.controller!.window!)
            controller.podfile = podfile
            
            return cellView
        } else {
            self.log.severe("Unknown DependencyDefinable type. TableViewCell loaded without controller. Data: \(self.controller?.dependencyDefinables?[safe: row])")
            return .None
        }
    }
    
    // MARK: Handle Cell Height
    
    private let cellHeightCalculationView: DefaultCartfileTableCellView = {
        let view = DefaultCartfileTableCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.viewDidLoad()
        view.setPrimaryTextFieldString("TestString")
        return view
    }()
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cartfile = self.controller?.dependencyDefinables?[safe: row] {
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