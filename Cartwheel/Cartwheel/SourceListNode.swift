//
//  SourceListNode.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 2/6/16.
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


class SourceListNode<T> {
    let title: String
    let children: [SourceListNode<T>]
    let item: T?
    
    weak var parent: SourceListNode?
    
    init(title: String, item: T?, children: [SourceListNode<T>]) {
        self.title = title
        self.item = item
        self.children = children
        for child in children {
            child.parent = self
        }
    }
    
    convenience init(title: String, children: [SourceListNode<T>]) {
        self.init(title: title, item: .None, children: children)
    }
    
    convenience init(title: String) {
        self.init(title: title, item: .None, children: [])
    }
    
    convenience init(title: String, item: T) {
        self.init(title: title, item: item, children: [])
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
    
    func nodeByAppendingChildren(newChildren: [SourceListNode<T>]) -> SourceListNode<T> {
        let allChildren = self.children + newChildren
        let newNode = SourceListNode(title: self.title, item: self.item, children: allChildren)
        return newNode
    }
}

extension SourceListNode: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(self.dynamicType): Title: \(self.title), HasChildren: \(self.children.count > 0), Item: \(self.item)"
    }
}