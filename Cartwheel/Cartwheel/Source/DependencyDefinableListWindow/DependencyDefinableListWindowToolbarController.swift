//
//  CartListWindowToolbar.swift
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
import PureLayout_Mac

final class DependencyDefinableListWindowToolbarController: DependencyDefinableListChildController, NSToolbarDelegate {
    
    // MARK: Main Properties
    let toolbar = NSToolbar(identifier: "CartListWindowToolbar")
    
    var searchFieldDelegate: NSTextFieldDelegate? {
        get { return self.cartfilesSearchField.delegate }
        set { self.cartfilesSearchField.delegate = newValue }
    }
    
    // MARK: Toolbar Items
    
    private let addCartfileButton = NSButton(style: .Default)
    private let createNewCartfileButton = NSButton(style: .Default)
    private let cartfilesSearchField = NSSearchField()
    private let cartfilesSearchFieldToolbarItem = NSToolbarItem(itemIdentifier: ToolbarItems.CartfilesSearchIdentifier)
    
    // MARK: Handle Init and Config
    
    override init() {
        super.init()
        
        // configure the search field
        let cartfilesSearchFieldTitle = NSLocalizedString("Search", comment: "Toolbar Item to search through cartfiles")
        let cartfilesSearchFieldToolTip = NSLocalizedString("Search through the list of Cartfiles", comment: "Tooltip for the toolbar item to search through cartfiles")
        self.configureToolbarItem(self.cartfilesSearchFieldToolbarItem, withView: self.cartfilesSearchField, title: cartfilesSearchFieldTitle, toolTip: cartfilesSearchFieldToolTip)
        
        // set initial toolbar properties
        self.toolbar.allowsUserCustomization = false
        self.toolbar.autosavesConfiguration = true
        self.toolbar.displayMode = NSToolbarDisplayMode.IconOnly
        self.toolbar.delegate = self
    }
    
    private func configureToolbarItem(toolbarItem: NSToolbarItem, withView view: NSView, title: String, toolTip: String) {
        if let view = view as? NSControl {
            view.sizeToFit()
        }
        
        // configure the search field toolbaritem
        toolbarItem.label = title
        toolbarItem.paletteLabel = title
        toolbarItem.toolTip = toolTip
        toolbarItem.view = view
        toolbarItem.minSize = view.frame.size
        toolbarItem.maxSize = NSSize(width: 999, height: view.frame.size.height)
    }
    
    // MARK: Constants
    
    struct ToolbarItems {
        static var CartfilesSearchIdentifier = "CartfilesSearchIdentifier"
        
        enum Identifier: String {
            case CartfilesSearchIdentifier = "CartfilesSearchIdentifier"
        }
    }
    
}

// MARK: NSTextFieldDelegate

extension DependencyDefinableListWindowToolbarController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(toolbar: NSToolbar) -> [AnyObject] {
        return [
            ToolbarItems.CartfilesSearchIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            NSToolbarSpaceItemIdentifier,
            NSToolbarSeparatorItemIdentifier
        ]
    }
    
    func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [AnyObject] {
        return [
            NSToolbarFlexibleSpaceItemIdentifier,
            ToolbarItems.CartfilesSearchIdentifier
        ]
    }
    
    func toolbar(toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let identifier = ToolbarItems.Identifier(rawValue: itemIdentifier) {
            switch identifier {
            case .CartfilesSearchIdentifier:
                return self.cartfilesSearchFieldToolbarItem
            }
        }
        return nil
    }
}