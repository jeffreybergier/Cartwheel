//
//  CartListWindowToolbarController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/23/15.
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

class CartListWindowToolbarController: NSObject {
    
    // MARK: Main Properties
    private let toolbar = NSToolbar(identifier: "CartListWindowToolbar")
    private let contentModel: CWCartfileDataSource
    private let log = XCGLogger.defaultInstance()
    private weak var parentWindowController: NSWindowController?
    private var window: NSWindow? {
        return parentWindowController?.window
    }
    
    // MARK: Toolbar Items
    
    private let addCartfileButton = NSButton.buttonWithDefaultStyle()
    private let createNewCartfileButton = NSButton.buttonWithDefaultStyle()
    private let cartfilesSearchField = NSSearchField()
    
    private let addCartfileButtonToolbarItem = NSToolbarItem(itemIdentifier: ToolbarItems.AddCartfileIdentifier)
    private let createNewCartfileToolbarItem = NSToolbarItem(itemIdentifier: ToolbarItems.CreateNewCartfileIdentifier)
    private let cartfilesSearchFieldToolbarItem = NSToolbarItem(itemIdentifier: ToolbarItems.CartfilesSearchIdentifier)
    
    // MARK: Handle Init and Config
    
    init(withinWindowController windowController: NSWindowController, dataSource: CWCartfileDataSource) {
        self.parentWindowController = windowController
        self.contentModel = dataSource
        super.init()
        
        // configure the add cartfile button
        let addCartfileButtonTitle = NSLocalizedString("Add Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
        let addCartfileButtonToolTip = NSLocalizedString("Add a Cartfile to the list of Cartfiles.", comment: "Tooltip for the toolbar item to add a new cartfoile to Cartwheel")
        self.configureToolbarItem(self.self.addCartfileButtonToolbarItem, view: addCartfileButton, title: addCartfileButtonTitle, toolTip: addCartfileButtonToolTip)
        self.addCartfileButton.action = "didClickAddCartFileButton:"
        self.addCartfileButton.target = self
        
        // configure the create cartfile button
        let createNewCartfileButtonTitle = NSLocalizedString("Create Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
        let createNewCartfileButtonToolTip = NSLocalizedString("Create a new Cartfile and add it to the list of Cartfiles.", comment: "Tooltip for the toolbar item to create a new Cartfile and then add it to Cartwheel")
        self.configureToolbarItem(self.createNewCartfileToolbarItem, view: self.createNewCartfileButton, title: createNewCartfileButtonTitle, toolTip: createNewCartfileButtonToolTip)
        self.createNewCartfileButton.action = "didClickCreateNewCartFileButton:"
        self.createNewCartfileButton.target = self
        
        // configure the search field
        let cartfilesSearchFieldTitle = NSLocalizedString("Search", comment: "Toolbar Item to search through cartfiles")
        let cartfilesSearchFieldToolTip = NSLocalizedString("Search through the list of Cartfiles", comment: "Tooltip for the toolbar item to search through cartfiles")
        self.configureToolbarItem(self.cartfilesSearchFieldToolbarItem, view: self.cartfilesSearchField, title: cartfilesSearchFieldTitle, toolTip: cartfilesSearchFieldToolTip)
        self.cartfilesSearchField.delegate = self
        
        // set initial toolbar properties
        self.toolbar.allowsUserCustomization = true
        self.toolbar.autosavesConfiguration = true
        self.toolbar.displayMode = NSToolbarDisplayMode.IconOnly
        self.toolbar.delegate = self
        windowController.window?.toolbar = self.toolbar
    }
    
    private func configureToolbarItem(toolbarItem: NSToolbarItem, view: NSView, title: String, toolTip: String) {
        // configure the view if necessary
        if let view = view as? NSButton {
            view.title = title
            view.sizeToFit()
        } else if let view = view as? NSSearchField {
            view.sizeToFit()
        }
        
        // configure the search field toolbaritem
        toolbarItem.label = title
        toolbarItem.paletteLabel = title
        toolbarItem.toolTip = toolTip
        toolbarItem.view = view
        toolbarItem.minSize = view.frame.size
        toolbarItem.maxSize = view.frame.size
    }
    
    // MARK: Handle Toolbar Button Actions
    
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
    
    //
    // These properties help with the NSOpenPanel Button Hijack
    // More info can be found under the NSOpenSavePanelDelegate MARK
    //
    private var savePanelShouldOpenURL: NSURL?
    private var savePanelDidChangeToDirectoryURL: NSURL?
    private weak var savePanel: NSOpenPanel?
    private let savePanelOriginalButtonTitle = NSLocalizedString("Create Cartfile", comment: "In the save sheet for creating a new cartifle, this button is the create new button")
    
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
    
    // MARK: Constants
    
    struct ToolbarItems {
        static var AddCartfileIdentifier = "AddCartfileIdentifier"
        static var CreateNewCartfileIdentifier = "CreateNewCartfileIdentifier"
        static var CartfilesSearchIdentifier = "CartfilesSearchIdentifier"
        
        enum Identifier: String {
            case AddCartfileIdentifier = "AddCartfileIdentifier"
            case CreateNewCartfileIdentifier = "CreateNewCartfileIdentifier"
            case CartfilesSearchIdentifier = "CartfilesSearchIdentifier"
        }
    }
    
}

// MARK: NSTextFieldDelegate

extension CartListWindowToolbarController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(toolbar: NSToolbar) -> [AnyObject] {
        return [
            ToolbarItems.AddCartfileIdentifier,
            ToolbarItems.CreateNewCartfileIdentifier,
            ToolbarItems.CartfilesSearchIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            NSToolbarSpaceItemIdentifier,
            NSToolbarSeparatorItemIdentifier
        ]
    }
    
    func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [AnyObject] {
        return [
            ToolbarItems.AddCartfileIdentifier,
            ToolbarItems.CreateNewCartfileIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            ToolbarItems.CartfilesSearchIdentifier
        ]
    }
    
    func toolbar(toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let identifier = ToolbarItems.Identifier(rawValue: itemIdentifier) {
            switch identifier {
            case .AddCartfileIdentifier:
                return self.addCartfileButtonToolbarItem
            case .CreateNewCartfileIdentifier:
                return self.createNewCartfileToolbarItem
            case .CartfilesSearchIdentifier:
                return self.cartfilesSearchFieldToolbarItem
            }
        }
        return nil
    }
}

// MARK: NSTextFieldDelegate

extension CartListWindowToolbarController: NSTextFieldDelegate {
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

extension CartListWindowToolbarController: NSOpenSavePanelDelegate {
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
