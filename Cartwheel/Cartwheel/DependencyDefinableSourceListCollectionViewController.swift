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

class DependencyDefinableSourceListViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var content = [SourceListNode<String>]()
    
    @IBOutlet weak var outlineView: NSOutlineView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subChild = SourceListNode<String>(title: "Subchild")
        let parentA = SourceListNode<String>(title: "ParentA", children: [SourceListNode<String>(title: "Child1A"), SourceListNode<String>(title: "Child2A"), SourceListNode<String>(title: "Child3A"), SourceListNode<String>(title: "Child4A")])
        let parentB = SourceListNode<String>(title: "ParentB", children: [SourceListNode<String>(title: "Child1B"), SourceListNode<String>(title: "Child2B", children: [subChild]), SourceListNode<String>(title: "Child3B")])
        let parentC = SourceListNode<String>(title: "ParentC", children: [SourceListNode<String>(title: "Child1C"), SourceListNode<String>(title: "Child2C")])
        
        self.content += [parentA] + [parentB] + [parentC]
        
        self.outlineView?.setDataSource(self)
        self.outlineView?.setDelegate(self)
        
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            // causes crash on launch if not delayed
            self.outlineView?.expandItem(.None, expandChildren: true)
        }
    }
    
    // MARK: NSOutlineViewDataSource
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        guard let item = item as? SourceListNode<String> else {
            // if this is NIL, that means the table is asking for the root level
            return self.content.count
        }
        
        return item.children.count
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        guard let item = item as? SourceListNode<String> else {
            // if this is NIL, that means the table is asking for the root level
            return self.content[index]
        }
        
        return item.children[index]
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let item = item as? SourceListNode<String> { return item.hasChildren } else { return false }
    }
    
    // MARK: NSOutlineViewDelegate
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if let item = item as? SourceListNode<String> {
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
        if let item = item as? SourceListNode<String> { return item.shouldDisplayAsGroupItem } else { return false }
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if let item = item as? SourceListNode<String> { return item.selectable } else { return false }
    }
    

}

// MARK: Custom Classe

class SourceListNode<T> {
    let title: String
    let children: [SourceListNode]
    var item: T?
    weak var parent: SourceListNode?
    
    var shouldDisplayAsGroupItem: Bool {
        if let _ = self.parent { return false } else { return true }
    }
    
    var selectable: Bool {
        if let _ = self.parent { return true } else { return false }
    }
    
    var hasChildren: Bool {
        return self.children.count > 0
    }
        
    init(title: String, item: T?, children: [SourceListNode]) {
        self.title = title
        self.children = children
        for child in children {
            child.parent = self
        }
    }
    
    convenience init(title: String, children: [SourceListNode]) {
        self.init(title: title, item: .None, children: children)
    }
    
    convenience init(title: String) {
        self.init(title: title, item: .None, children: [])
    }
}













