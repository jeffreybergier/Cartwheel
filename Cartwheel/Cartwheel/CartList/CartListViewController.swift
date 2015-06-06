//
//  File.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/27/15.
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
import PureLayout_Mac

class CartListViewController: NSViewController {

    private let dataSource = CWCartfileDataSource.sharedInstance
    private var contentView = CartListView()
    @IBOutlet private weak var window: NSWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure my view and add in the custom view
        self.view.wantsLayer = true
        self.view.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        
        // configure the main view
        self.contentView.controller = self
        self.contentView.viewDidLoad()
        
        // set the delegate on the tableview
        self.contentView.ui.tableView.setDataSource(self)
        self.contentView.ui.tableView.setDelegate(self)
        self.contentView.ui.tableView.reloadData()
        
        // Set the first responder
        self.contentView.ui.filterField.becomeFirstResponder()
    }
}

extension CartListViewController { // Handle Clicking Add Cartfile button
    @objc private func didClickAddCartFileButton(sender: NSButton) {
        let fileChooser = NSOpenPanel()
        fileChooser.canChooseFiles = true
        fileChooser.canChooseDirectories = true
        fileChooser.allowsMultipleSelection = true
        
        fileChooser.beginSheetModalForWindow(self.window!) { (untypedResult) -> Void in
            let result = NSFileHandlingPanelResponse(rawValue: untypedResult)!
            switch result {
            case .OKButton:
                for object in fileChooser.URLs {
                    var changedDataSource = false
                    if let url = object as? NSURL,
                        let cartfiles = self.parseCartfilesFromURL(url) {
                            changedDataSource = true
                            self.dataSource.addCartfiles(cartfiles)
                    }
                    if changedDataSource == true {
                        self.contentView.ui.tableView.reloadData()
                    }
                }
            case .CancelButton:
                NSLog("CartListViewController: File Chooser was cancelled by user.")
            }
        }
    }
    
    @objc private func didClickCreateNewCartFileButton(sender: NSButton) {
        NSLog("Create new cartfile")
    }
    
    private func parseCartfilesFromURL(url: NSURL) -> [CWCartfile]? {
        if url.lastPathComponent?.lowercaseString == self.dataSource.defaultsPlist.cartfileFileName {
            return [url]
        } else {
            var isDirectory: ObjCBool = false
            NSFileManager.defaultManager().fileExistsAtPath(url.path!, isDirectory: &isDirectory)
            if let cartfiles = self.parseCartfilesByEnumeratingURL(url, directoryRecursionDepth: 0, initialCartfiles: nil) {
                self.dataSource.addCartfiles(cartfiles)
                self.contentView.ui.tableView.reloadData()
            }
        }
        return nil
    }
    
    private func parseCartfilesByEnumeratingURL(parentURL: NSURL, directoryRecursionDepth: Int, initialCartfiles: [CWCartfile]?) -> [CWCartfile]? {
        if directoryRecursionDepth <= self.dataSource.defaultsPlist.cartfileDirectorySearchRecursion {
            
            let fileManager = NSFileManager.defaultManager()
            let keys = [NSURLIsDirectoryKey]
            let options: NSDirectoryEnumerationOptions = .SkipsHiddenFiles | .SkipsPackageDescendants | .SkipsSubdirectoryDescendants
            
            let enumerator = fileManager.enumeratorAtURL(parentURL, includingPropertiesForKeys: keys, options: options) {
                (url: NSURL?, error: NSError?) -> Bool in
                NSLog("CartListViewController: NSEnumerator Error: \(error) with URL: \(url)")
                return true
            }
            
            var cartfiles = [CWCartfile]()
            for object in enumerator!.allObjects {
                if let url = object as? NSURL,
                    let urlResources = url.resourceValuesForKeys(keys, error: nil),
                    let urlIsDirectory = urlResources[NSURLIsDirectoryKey] as? Bool {
                        if urlIsDirectory == false {
                            if url.lastPathComponent?.lowercaseString == self.dataSource.defaultsPlist.cartfileFileName.lowercaseString {
                                cartfiles += [url]
                                println("Cartfile found at URL: \(url)")
                            }
                        } else {
                            if let recursiveCartfiles = self.parseCartfilesByEnumeratingURL(url, directoryRecursionDepth: directoryRecursionDepth + 1, initialCartfiles: cartfiles) {
                                cartfiles += recursiveCartfiles
                            }
                        }
                }
            }
            return cartfiles
        }
        return nil
    }
}

extension CartListViewController: NSTextFieldDelegate {
    override func controlTextDidChange(notification: NSNotification) {
        if let userInfoDictionary = notification.userInfo,
            let filterTextField = userInfoDictionary["NSFieldEditor"] as? NSTextView,
            let stringValue = filterTextField.string {
                NSLog("\(stringValue)")
        }
    }

    override func controlTextDidEndEditing(notification: NSNotification) {
        if let userInfoDictionary = notification.userInfo,
            let filterTextField = userInfoDictionary["NSFieldEditor"] as? NSTextView,
            let stringValue = filterTextField.string {
                NSLog("\(stringValue)")
        }
    }
}

extension CartListViewController: NSTableViewDelegate {
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}

extension CartListViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.dataSource.cartfiles.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("CartListTableCellViewController", owner: self) as? CartListTableCellViewController
        cell?.cartfileURL = self.dataSource.cartfiles[advance(self.dataSource.cartfiles.startIndex, row)]
        return cell
    }
}
