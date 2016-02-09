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
import JSBUtils

class DependencyDefinableSourceListViewController: NSViewController {
    
    // MARK: Properties

    private var content = Model() {
        didSet {
            self.sidebarController.content = self.content.nodeVersion()
        }
    }
    
    private var detailViewController: DependencyDefinableDetailViewController? {
        let splitVC = self.parentViewController as? NSSplitViewController
        let possibleDetailVCs = splitVC?.childViewControllers.filter() { vc -> Bool in
            return vc is DependencyDefinableDetailViewController
            }.map() { vc -> DependencyDefinableDetailViewController in
                return vc as! DependencyDefinableDetailViewController
        }
        return possibleDetailVCs?.first
    }
    
    // MARK: Helper Controllers
    
    private let sidebarController = SourceListController<DependencyDefinable>()
    private let diskManager = JSBDictionaryPLISTPreferenceManager()
    
    // MARK: Interface Builder
    
    @IBOutlet private weak var outlineView: NSOutlineView?
    
    // MARK: View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let outlineView = self.outlineView {
            self.sidebarController.sourceListView = outlineView
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "outlineViewSelectionDidChange:",
                name: NSOutlineViewSelectionDidChangeNotification,
                object: outlineView)
        }

        self.content = Model(diskManager: self.diskManager)
    }
    
    // MARK: Handle User Input
    
    @objc private func outlineViewSelectionDidChange(notification: NSNotification) {
        let selectedItem = self.sidebarController.selectedItem()
        print(selectedItem)
        self.detailViewController?.content = selectedItem
    }
    
    @IBAction func deleteButtonClicked(sender: NSButton?) {
        var mutableContent = self.content
        try! mutableContent.removeItem(self.sidebarController.selectedItem())
        let immutableContent = mutableContent
        try! immutableContent.saveToDiskWithManager(self.diskManager)
        self.content = immutableContent
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
                
                let newCartfiles = openPanel.URLs.map() { url -> Cartfile? in
                        return Cartfile(url: url)
                    }.filter() { cartfile -> Bool in
                        return cartfile != nil
                    }.map() { cartfile -> Cartfile in
                        return cartfile!
                }
                
                do {
                    var mutableContent = self.content
                    mutableContent.appendContent(newCartfiles, newPodfiles: [])
                    let immutableContent = mutableContent
                    try immutableContent.saveToDiskWithManager(self.diskManager)
                    self.content = immutableContent
                } catch {
                    print("Error Saving to Disk \(error)")
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













