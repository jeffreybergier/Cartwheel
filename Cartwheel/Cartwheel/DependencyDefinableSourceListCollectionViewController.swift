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
    
    private let sidebarController = SourceListController<NSURL>()
    @IBOutlet private weak var outlineView: NSOutlineView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cartfileParent = SourceListNode<NSURL>(title: "Cartfile")
        let podfileParent = SourceListNode<NSURL>(title: "Podfile")
        
        let content = [cartfileParent] + [podfileParent]
        
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
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Choose File"
        openPanel.worksWhenModal = true
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.resolvesAliases = true
        openPanel.beginSheetModalForWindow(self.view.window!) { response in
            if response == 1 { // file chosen
                for url in openPanel.URLs {
                    let titleURL = url.URLByDeletingLastPathComponent
                    let title = titleURL?.lastPathComponent ?? "Unknown Directory"
                    let childNode = SourceListNode<NSURL>(title: title, item: url)
                    if let cartfileNode = self.sidebarController.content.first {
                        let newNode = cartfileNode.nodeByAppendingChildren([childNode])
                        self.sidebarController.content[0] = newNode
                    }
                }
            }
        }
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













