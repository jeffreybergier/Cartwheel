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

class DependencyDefinableSourceListViewController: NSViewController {
    
    private let sidebarController = SourceListController<String>()
    @IBOutlet private weak var outlineView: NSOutlineView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subChild = SourceListNode<String>(title: "Subchild")
        let parentA = SourceListNode<String>(title: "ParentA", children: [SourceListNode<String>(title: "Child1A"), SourceListNode<String>(title: "Child2A"), SourceListNode<String>(title: "Child3A"), SourceListNode<String>(title: "Child4A")])
        let parentB = SourceListNode<String>(title: "ParentB", children: [SourceListNode<String>(title: "Child1B"), SourceListNode<String>(title: "Child2B", children: [subChild]), SourceListNode<String>(title: "Child3B")])
        let parentC = SourceListNode<String>(title: "ParentC", children: [SourceListNode<String>(title: "Child1C"), SourceListNode<String>(title: "Child2C")])
        
        let content = [parentA] + [parentB] + [parentC]
        
        self.sidebarController.sourceListView = self.outlineView
        self.sidebarController.content = content
        
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            // causes crash on launch if not delayed
            self.outlineView?.expandItem(.None, expandChildren: true)
        }
    }
    
    private func createNewButtonClicked(sender: NSButton?) {
        print("createNewButtonClicked")
    }
    
    private func openExistingButtonClicked(sender: NSButton?) {
        print("openExistingButtonClicked")
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        guard let segueID = StoryboardSegue.optionalRawValue(segue.identifier) else { return }
        switch segueID {
        case .AddDependencyDefinablePopover:
            guard let destinationVC = segue.destinationController as? TwoButtonViewController else { return }
            destinationVC.button1ActionClosure = self.createNewButtonClicked
            destinationVC.button2ActionClosure = self.openExistingButtonClicked
            break
        }
    }
    
}













