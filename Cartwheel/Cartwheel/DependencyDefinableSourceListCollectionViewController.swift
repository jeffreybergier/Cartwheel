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

class Node: NSObject {
    let data: String
    var children: [Node] = []
    init(data: String) {
        self.data = data
    }
    func isLeaf() -> Bool {
        if children.isEmpty {
            return true
        } else {
            return false
        }
    }
}

class DependencyDefinableSourceListViewController: NSViewController {
    
    dynamic var sidebarItems = [Node]()
    @IBOutlet var treeController: NSTreeController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let aNode = Node(data: "Parent A")
        aNode.children.append(Node(data: "Child1 A"))
        aNode.children.append(Node(data: "Child2 A"))
        self.treeController.addObject(aNode)
        let bNode = Node(data: "Parent B")
        bNode.children.append(Node(data: "Child1 B"))
        bNode.children.append(Node(data: "Child2 B"))
        self.treeController.addObject(bNode)
    }
}