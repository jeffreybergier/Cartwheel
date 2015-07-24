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

class CartListWindowToolbarController: NSObject, NSToolbarDelegate {
    
    private let toolbar = NSToolbar(identifier: "CartListWindowToolbar")
    private weak var parentWindowController: NSWindowController?
    private var window: NSWindow? {
        return parentWindowController?.window
    }
    
    private let addCartfileButton = NSButton.buttonWithDefaultStyle()
    private let createNewCartfileButton = NSButton.buttonWithDefaultStyle()
    private let cartfilesSearchField = NSSearchField()
    
    private let addCartfileButtonToolbarItem = NSToolbarItem(itemIdentifier: ToolbarItems.AddCartfileIdentifier)
    private let createNewCartfileToolbarItem = NSToolbarItem(itemIdentifier: ToolbarItems.CreateNewCartfileIdentifier)
    private let cartfilesSearchFieldToolbarItem = NSToolbarItem(itemIdentifier: ToolbarItems.CartfilesSearchIdentifier)
    
    init(withinWindowController windowController: NSWindowController) {
        self.parentWindowController = windowController
        super.init()
        
        // configure the add cartfile button
        let addCartfileButtonTitle = NSLocalizedString("Add Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
        let addCartfileButtonToolTip = NSLocalizedString("Add a Cartfile to the list of Cartfiles.", comment: "Tooltip for the toolbar item to add a new cartfoile to Cartwheel")
        self.configureToolbarItem(addCartfileButtonToolbarItem, view: addCartfileButton, title: addCartfileButtonTitle, toolTip: addCartfileButtonToolTip)
        
        // configure the create cartfile button
        let createNewCartfileButtonTitle = NSLocalizedString("Create Cartfile", comment: "Button to Add a Cartfile to Cartwheel")
        let createNewCartfileButtonToolTip = NSLocalizedString("Create a new Cartfile and add it to the list of Cartfiles.", comment: "Tooltip for the toolbar item to create a new Cartfile and then add it to Cartwheel")
        self.configureToolbarItem(createNewCartfileToolbarItem, view: createNewCartfileButton, title: createNewCartfileButtonTitle, toolTip: createNewCartfileButtonToolTip)
        
        // configure the search field
        let cartfilesSearchFieldTitle = NSLocalizedString("Search", comment: "Toolbar Item to search through cartfiles")
        let cartfilesSearchFieldToolTip = NSLocalizedString("Search through the list of Cartfiles", comment: "Tooltip for the toolbar item to search through cartfiles")
        self.configureToolbarItem(self.cartfilesSearchFieldToolbarItem, view: self.cartfilesSearchField, title: cartfilesSearchFieldTitle, toolTip: cartfilesSearchFieldToolTip)
        
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
        toolbarItem.paletteLabel = toolbarItem.label
        toolbarItem.toolTip = toolTip
        toolbarItem.view = view
        toolbarItem.minSize = view.frame.size
        toolbarItem.maxSize = view.frame.size
    }
    
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
