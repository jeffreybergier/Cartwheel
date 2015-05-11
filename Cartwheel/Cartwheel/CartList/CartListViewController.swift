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
        NSLog("clicked button")
        
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
                            println(url)
                        }
                    }
                default:
                    println("something bad happened with the file chooser")
                }
            })
        }
    
//        NSOpenPanel *panel = [NSOpenPanel openPanel];
//        [panel setCanChooseFiles:NO];
//        [panel setCanChooseDirectories:YES];
//        [panel setAllowsMultipleSelection:YES]; // yes if more than one dir is allowed
//        
//        NSInteger clicked = [panel runModal];
//        
//        if (clicked == NSFileHandlingPanelOKButton) {
//            for (NSURL *url in [panel URLs]) {
//                // do something with the url here.
//            }
//        }
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
        return self.dataSource.cartFiles.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("CartListTableCellViewController", owner: self) as? CartListTableCellViewController
        return cell
    }
}
