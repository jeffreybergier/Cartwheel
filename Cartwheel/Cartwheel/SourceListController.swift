//
//  SourceListController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 2/5/16.
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

class SourceListController<T>:NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var content = [SourceListNode<T>]() {
        didSet {
            self.sourceListView?.reloadData()
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                // causes crash on launch if not delayed
                self.sourceListView?.expandItem(.None, expandChildren: true)
            }
        }
    }
    
    weak var sourceListView: NSOutlineView? {
        didSet {
            self.sourceListView?.setDelegate(self)
            self.sourceListView?.setDataSource(self)
        }
    }
    
    // MARK: NSOutlineViewDataSource
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        guard let item = item as? SourceListNode<T> else {
            // if this is NIL, that means the table is asking for the root level
            return self.content.count
        }
        
        return item.children.count
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        guard let item = item as? SourceListNode<T> else {
            // if this is NIL, that means the table is asking for the root level
            return self.content[index]
        }
        
        return item.children[index]
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let item = item as? SourceListNode<T> { return item.hasChildren } else { return false }
    }
    
    // MARK: NSOutlineViewDelegate
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if let item = item as? SourceListNode<T> {
            if item.children.count > 0 && item.parent == nil {
                let cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView
                cell?.textField?.stringValue = item.title
                return cell
            } else {
                let cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView
                cell?.textField?.stringValue = item.title
                cell?.imageView?.image = .None
                return cell
            }
        }
        return .None
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        if let item = item as? SourceListNode<T> { return item.shouldDisplayAsGroupItem } else { return false }
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if let item = item as? SourceListNode<T> { return item.selectable } else { return false }
    }
    
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        return 25
    }
}

