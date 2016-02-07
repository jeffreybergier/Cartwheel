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
    
    @IBOutlet private weak var outlineView: NSOutlineView?
    
    private var content = DependencyDefinableContent() {
        didSet {
            self.sidebarController.content = self.content.nodeVersion()
        }
    }
    
    private let sidebarController = SourceListController<DependencyDefinable>()
    private let diskManager = JSBDictionaryPLISTPreferenceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sidebarController.sourceListView = self.outlineView
        
        let contentDictionary: [String : [NSDictionary]]?
        do {
            let untypedDictionary = try self.diskManager.dictionaryByReadingPLISTFromDiskLocation(.AppDirectoryWithinAppSupportDirectory(lastPathComponent: "Cartwheel.plist"))
            contentDictionary = untypedDictionary as? [String : [NSDictionary]]
        } catch {
            contentDictionary = .None
        }
        
        let cartfilesArray: [Cartfile]
        if let cartfileDictionaryArray = contentDictionary?["Cartfile"] {
            cartfilesArray = cartfileDictionaryArray.map() { dictionary -> Cartfile? in
                return Cartfile(dictionary: dictionary)
                }.filter() { cartfile -> Bool in
                    return cartfile != nil
                }.map() { cartfile -> Cartfile in
                    return cartfile!
            }
        } else {
            cartfilesArray = []
        }
        
        let podfilesArray: [DependencyDefinable] = []
        self.content = DependencyDefinableContent(cartfiles: cartfilesArray, podfiles: podfilesArray)
    }
    
    private func updateContentAndSaveToDisk(newContent: DependencyDefinableContent) throws {
        let writableCartfiles = newContent.cartfiles.map() { cartfile -> NSDictionary in
            return cartfile.dictionaryVersion()
        }
        let writeablePodfiles = newContent.podfiles.map() { podfile -> NSDictionary in
            return podfile.dictionaryVersion()
        }
        let dictionary = [
            "Cartfile" : writableCartfiles,
            "Podfile" : writeablePodfiles
        ]
        
        do {
            try self.diskManager.writePLISTDictionary(dictionary, toLocation: .AppDirectoryWithinAppSupportDirectory(lastPathComponent: "Cartwheel.plist"), options: .AtomicWrite)
            self.content = newContent
        } catch {
            throw error
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
                let newCartfiles = openPanel.URLs.map() { url -> Cartfile? in
                        return Cartfile(url: url)
                    }.filter() { cartfile -> Bool in
                        return cartfile != nil
                    }.map() { cartfile -> Cartfile in
                        return cartfile!
                }
                try! self.updateContentAndSaveToDisk(DependencyDefinableContent(cartfiles: self.content.cartfiles + newCartfiles, podfiles: self.content.podfiles))
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
    
    struct DependencyDefinableContent {
        var cartfiles: [Cartfile]
        var podfiles: [DependencyDefinable]
        
        init() {
            self.cartfiles = []
            self.podfiles = []
        }
        
        init(cartfiles: [Cartfile], podfiles: [DependencyDefinable]) {
            self.cartfiles = cartfiles
            self.podfiles = podfiles
        }
        
        func nodeVersion() -> [SourceListNode<DependencyDefinable>] {
            let cartfileChildren = self.cartfiles.map() { cartfile -> SourceListNode<DependencyDefinable> in
                return SourceListNode(title: cartfile.title, item: cartfile)
            }
            let podfileChildren = self.podfiles.map() { podfile -> SourceListNode<DependencyDefinable> in
                return SourceListNode(title: podfile.title, item: podfile)
            }
            let cartfileParent = SourceListNode(title: "Cartfiles", children: cartfileChildren)
            let podfileParent = SourceListNode(title: "Podfiles", children: podfileChildren)
            
            return [cartfileParent] + [podfileParent]
        }
    }
}













