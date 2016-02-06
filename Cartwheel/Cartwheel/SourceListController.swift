//
//  SourceListController.swift
//  Cartwheel
//
//  Created by aGitated crAnberries on 2/5/16.
//  Copyright © 2016 Saturday Apps. All rights reserved.
//

import Cocoa

// MARK: Custom Classe

class SourceListNode<T> {
    let title: String
    let children: [SourceListNode]
    var item: T?
    weak var parent: SourceListNode?
    
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
    
    var shouldDisplayAsGroupItem: Bool {
        if let _ = self.parent { return false } else { return true }
    }
    
    var selectable: Bool {
        if let _ = self.parent { return true } else { return false }
    }
    
    var hasChildren: Bool {
        return self.children.count > 0
    }
}

class SourceListController<T>:NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var content = [SourceListNode<T>]() {
        didSet {
            self.sourceListView?.reloadData()
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
}

