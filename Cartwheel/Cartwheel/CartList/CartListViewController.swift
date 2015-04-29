//
//  File.swift
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
import SAWindowBackedViewController

class CartListViewController: SAWindowBackedViewController {
    
    var cartListView: CartListView {
        if let view = self.view as? CartListView {
            return view
        } else {
            fatalError("CartListViewController: self.view is either NIL or not of type CartListView: \(self.view)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("CartListViewController Did Load")
        
        // configure the main view
        self.cartListView.controller = self
        self.cartListView.viewDidLoad()
        
        // set the delegate on the tableview
        self.cartListView.tableViewContainer.tableView.setDataSource(self)
        self.cartListView.tableViewContainer.tableView.setDelegate(self)
        self.cartListView.tableViewContainer.tableView.reloadData()
    }
    
}

extension CartListViewController: NSTableViewDelegate {
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}

extension CartListViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 60
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("CartListTableCellViewController", owner: self) as? CartListTableCellViewController
        return cell
    }
}
