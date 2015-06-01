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
        
        // prepare fake data
        self.prepareFakeData()
        
        // set the delegate on the tableview
        self.contentView.ui.tableView.setDataSource(self)
        self.contentView.ui.tableView.setDelegate(self)
        self.contentView.ui.tableView.reloadData()
        
        // Set the first responder
        self.contentView.ui.filterField.becomeFirstResponder()
    }
    
    private func prepareFakeData() {
        let fakeDataArray = [
            CWCartfile(locationOnDisk: NSURL(string: "fakeurlcartfile1")!),
            CWCartfile(locationOnDisk: NSURL(string: "fakeurlcartfile2")!),
            CWCartfile(locationOnDisk: NSURL(string: "fakeurlcartfile3")!),
            CWCartfile(locationOnDisk: NSURL(string: "fakeurlcartfile4")!)
        ]
        
        fakeDataArray.map { (cartfile) -> Void in
            self.dataSource.addCartfile(cartfile)
        }
    }
}

extension CartListViewController { // Handle Clicking Add Cartfile button
    @objc private func didClickAddCartFileButton(sender: NSButton) {
        if let window = self.window {
            let fileChooser = NSOpenPanel()
            fileChooser.canChooseFiles = true
            fileChooser.canChooseDirectories = true
            fileChooser.allowsMultipleSelection = false
            
            fileChooser.beginSheetModalForWindow(window, completionHandler: { (result) -> Void in
                switch result {
                case NSFileHandlingPanelOKButton:
                    for object in fileChooser.URLs {
                        if let url = object as? NSURL {
                            let cartfiles = self.parseCartfilesFromURL(url)
                        }
                    }
                default:
                    NSLog("CartListViewController: File Chooser was cancelled or dismissed for another reason.")
                }
            })
        }
    }
    
    @objc private func didClickCreateNewCartFileButton(sender: NSButton) {
        NSLog("Create new cartfile")
    }
    
    private func parseCartfilesFromURL(url: NSURL) -> [CWCartfile]? {
        if url.lastPathComponent?.lowercaseString == "cartfile" {
            return [CWCartfile(locationOnDisk: url)]
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
        let fileManager = NSFileManager.defaultManager()
        let keys = [NSURLIsDirectoryKey]
        let options: NSDirectoryEnumerationOptions = .SkipsHiddenFiles | .SkipsPackageDescendants | .SkipsSubdirectoryDescendants
        
        let enumerator = fileManager.enumeratorAtURL(parentURL, includingPropertiesForKeys: keys, options: options) {
            (url: NSURL?, error: NSError?) -> Bool in
            NSLog("CartListViewController: NSEnumerator Error: \(error) with URL: \(url)")
            return true
        }
        
        var cartfiles = [CWCartfile]()
        if directoryRecursionDepth < 4 {
            if let enumeratorArray = enumerator?.allObjects {
                for object in enumeratorArray {
                    if let url = object as? NSURL,
                        let urlResources = url.resourceValuesForKeys(keys, error: nil),
                        let isDirectory = urlResources[NSURLIsDirectoryKey] as? Bool {
                            if isDirectory == false {
                                if url.lastPathComponent?.lowercaseString == "cartfile" {
                                    cartfiles += [CWCartfile(locationOnDisk: url)]
                                    println("Cartfile found! URL: \(url)")
                                }
                            } else {
                                if let recursiveCartfiles = self.parseCartfilesByEnumeratingURL(url, directoryRecursionDepth: directoryRecursionDepth + 1, initialCartfiles: cartfiles) {
                                    cartfiles += recursiveCartfiles
                                }
                            }
                    }
                }
            }
        }
        
        return cartfiles
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
        return cell
    }
}
