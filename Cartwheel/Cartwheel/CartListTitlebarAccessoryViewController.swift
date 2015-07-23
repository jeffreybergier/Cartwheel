//
//  CartListTitlebarAccessoryViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 6/6/15.
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
import XCGLogger
import PureLayout_Mac

@objc(CartListTitlebarAccessoryViewController) // this is required so the NIB can be found by cocoa
final class CartListTitlebarAccessoryViewController: NSTitlebarAccessoryViewController {
    
    // Model, View Controller Properties
    var contentModel: CWCartfileDataSource!
    weak var parentWindowController: NSWindowController?
    
    private var window: NSWindow? { return self.parentWindowController?.window }
    
    private let contentView = CartListTitlebarAccessoryView()
    private let log = XCGLogger.defaultInstance()
    
    //
    // These properties help with the NSOpenPanel Button Hijack
    // More info can be found under the NSOpenSavePanelDelegate MARK
    //
    private var savePanelShouldOpenURL: NSURL?
    private var savePanelDidChangeToDirectoryURL: NSURL?
    private weak var savePanel: NSOpenPanel?
    private let savePanelOriginalButtonTitle = NSLocalizedString("Create Cartfile", comment: "In the save sheet for creating a new cartifle, this button is the create new button")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure view to do blur properly
        if let view = self.view as? NSVisualEffectView {
            view.blendingMode = .BehindWindow
            view.material = .Titlebar
            // TODO: Figure out how to change this to .Right
            self.layoutAttribute = .Bottom
        }
        
        //Add in the Contentview and Configure it
        self.view.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        self.contentView.viewDidLoadWithController(self)
        
        // configure titles for controls
        self.contentView.setMiddleButtonTitle(NSLocalizedString("Create Cartfile", comment: "Button to Add a Cartfile to Cartwheel"))
        self.contentView.setLeftButtonTitle(NSLocalizedString("Add Cartfile", comment: "Button to Add a Cartfile to Cartwheel"))
        
        // configure target action for controls
        self.contentView.setMiddleButtonAction("didClickCreateNewCartFileButton:", forTarget: self)
        self.contentView.setLeftButtonAction("didClickAddCartFileButton:", forTarget: self)
        self.contentView.setSearchFieldDelegate(self)
    }
}

// MARK: Handle Toolbar Buttons

extension CartListTitlebarAccessoryViewController { // Handle Clicking Add Cartfile button
    @objc private func didClickAddCartFileButton(sender: NSButton) {
        let fileChooser = NSOpenPanel()
        fileChooser.canChooseFiles = true
        fileChooser.canChooseDirectories = true
        fileChooser.allowsMultipleSelection = true
        
        fileChooser.beginSheetModalForWindow(self.window!) { untypedResult in
            let result = NSFileHandlingPanelResponse(rawValue: untypedResult)!
            switch result {
            case .SuccessButton:
                if let cartfiles = self.contentModel.cartfilesFromURL(fileChooser.URLs) {
                    self.contentModel.addCartfiles(cartfiles)
                }
            case .CancelButton:
                NSLog("CartListViewController: File Chooser was cancelled by user.")
            }
        }
    }

    @objc private func didClickCreateNewCartFileButton(sender: NSButton) {
        let savePanel = NSOpenPanel()
        savePanel.delegate = self
        savePanel.canChooseDirectories = true
        savePanel.canCreateDirectories = true
        savePanel.canChooseFiles = false
        savePanel.allowsMultipleSelection = false
        savePanel.title = NSLocalizedString("Create New Cartfile", comment: "Title of the create new cartfile save dialog.")
        savePanel.prompt = self.savePanelOriginalButtonTitle
        savePanel.beginSheetModalForWindow(self.window!, completionHandler: { untypedResult in
            let result = NSFileHandlingPanelResponse(rawValue: untypedResult)!
            switch result {
            case .SuccessButton:
                if let selectedURL = savePanel.URL {
                    let cartfileWriteResult = self.contentModel.writeBlankCartfileToDirectoryPath(selectedURL)
                    if let error = cartfileWriteResult.error {
                        let alert = NSAlert(error: error)
                        savePanel.orderOut(nil) // TODO: try to remove this later. Its not supposed to be needed.
                        alert.beginSheetModalForWindow(self.window!, completionHandler: nil)
                        self.log.error("\(error)")
                    } else {
                        let cartfile: CWCartfile = cartfileWriteResult.finalURL
                        self.contentModel.addCartfile(cartfile)
                        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([cartfile])
                    }
                }
            case .CancelButton:
                self.log.info("CartListViewController: File Saver was cancelled by user.")
            }
        })
        self.savePanel = savePanel // this allows us to hack the save panel with the hacky code under NSOpenSavePanelDelegate.
    }
}

// MARK: NSTextFieldDelegate

extension CartListTitlebarAccessoryViewController: NSTextFieldDelegate {
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

// MARK: NSOpenSavePanelDelegate

//
// Here begins a __sort of__ hack
// The default behavior of NSOpenPanel is to let someone select a folder and close the panel
// This could be pretty confusing because we will be saving the file INSIDE the folder they selected
// instead of the folder they were viewing
//
// This code hijacks NSOpenPanel primary button when the user selects a folder
// We then handle the click action from the button and tell NSOpenPanel to open the selected folder
// When the directory seen by the user matches the "selected" directory of the open panel
// then we return the button behavior to normal
//

extension CartListTitlebarAccessoryViewController: NSOpenSavePanelDelegate {
    func panel(sender: AnyObject?, didChangeToDirectoryURL url: NSURL?) {
        if self.savePanel === sender {
            self.savePanelDidChangeToDirectoryURL = url
        }
    }
    
    func panelSelectionDidChange(sender: AnyObject?) {
        if let sender = sender as? NSOpenPanel,
            let selectedURL = sender.URL
            where sender === self.savePanel {
                if selectedURL == self.savePanelDidChangeToDirectoryURL {
                    // change the button back to normal
                    sender.defaultButtonCell()?.target = sender
                    sender.defaultButtonCell()?.title = self.savePanelOriginalButtonTitle
                } else {
                    // Hijack the button
                    self.savePanelShouldOpenURL = selectedURL
                    sender.defaultButtonCell()?.title = NSLocalizedString("Open Folder", comment: "text in the prompt button of the create new cartfile button when it is instructing the user to open the selected folder")
                    sender.defaultButtonCell()?.target = self
                }
        }
    }
    
    @objc private func ok(sender: AnyObject?) {
        if let savePanel = self.savePanel,
            let shouldOpenURL = self.savePanelShouldOpenURL {
                // tell the panel to browse to the desired URL
                savePanel.directoryURL = shouldOpenURL
                self.savePanelShouldOpenURL = nil
        }
    }
}