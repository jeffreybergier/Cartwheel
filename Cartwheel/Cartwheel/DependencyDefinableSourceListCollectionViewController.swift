//
//  DependencyDefinableSourceListCollectionViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 1/17/16.
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

class Parent: CustomStringConvertible {
    let title: String
    let children: [String]
    
    init(title: String, children: [String]) {
        self.title = title
        self.children = children
    }
    
    var description: String {
        return "Parent<\(self.title)>"
    }
}

class DependencyDefinableSourceListViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    @IBOutlet private weak var sidebarSourceListView: NSOutlineView?
    private var sidebarItems = [Parent]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parentA = Parent(title: "Parent A", children: ["Child1A", "Child2A", "Child3A", "Child4A"])
        let parentB = Parent(title: "Parent B", children: ["Child1B", "Child2B", "Child3B"])
        let parentC = Parent(title: "Parent C", children: ["Child1C", "Child2C"])
        self.sidebarItems += [parentA] + [parentB] + [parentC]
        
        self.sidebarSourceListView?.setDataSource(self)
        self.sidebarSourceListView?.setDelegate(self)
        
        //self.sidebarSourceListView?.reloadData()
    }
    
    // MARK: NSOutlineViewDataSource
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let item = item as? Parent {
            let count = item.children.count
            print("numberOfChildrenOfItem: Item: \(item) Return Count: \(count)")
            return count
        } else {
            let count = self.sidebarItems.count
            print("numberOfChildrenOfItem: Item: \(item) Return Count: \(count)")
            return count
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let item = item as? Parent {
            let returnObject = item.children[index]
            print("numberOfChildrenOfItem: Item: \(item) Return Object: \(returnObject) atIndex: \(index)")
            return returnObject
        } else {
            let returnObject = self.sidebarItems[index]
            print("numberOfChildrenOfItem: Item: \(item) Return Object: \(returnObject) atIndex: \(index)")
            return returnObject
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let _ = item as? Parent {
            return true
        } else {
            return false
        }
    }
    
    // MARK: NSOutlineViewDelegate
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        print("viewForTableColumn: \(item)")
        if let item = item as? Parent {
            let cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            cell.textField!.stringValue = item.title
            return cell
        } else if let item = item as? String {
            let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            cell.textField!.stringValue = item
            return cell
        } else {
            let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            cell.textField!.stringValue = "Something Went Wrong"
            return cell
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return false // temporary while troubleshooting
        
        if let _ = item as? Parent {
            return true
        } else {
            return false
        }
    }

}













