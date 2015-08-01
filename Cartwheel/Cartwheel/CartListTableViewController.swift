//
//  CartListTableViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/2/15.
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
import XCGLogger
import ObserverSet

@objc(CartListTableViewController)
final class CartListTableViewController: NSViewController, NSTableViewDelegate, EventPassingButtonDelegate, CWCartfileDataSourceController {
    
    // Logging Object
    private let log = XCGLogger.defaultInstance()
    
    // View Object
    private let contentView = CartListView()
    
    // Model Object
    let contentModel: CWCartfileDataSource
    
    // Parent Controller
    private weak var parentWindowController: NSWindowController?
    private var window: NSWindow? {
        return self.parentWindowController?.window
    }
    
    // Window Observer
    let windowObserver: CartListWindowObserver
    
    // Child Controllers
    let tableViewDataSource: CartListTableViewDataSource
    let tableViewDelegate: CartListTableViewDelegate
    
    private let PUBLIC_TEXT_TYPES = [NSFilenamesPboardType]
    
    init?(controller: NSWindowController, model: CWCartfileDataSource, windowObserver: CartListWindowObserver) {
        self.contentModel = model
        self.parentWindowController = controller
        self.windowObserver = windowObserver
        self.tableViewDataSource = CartListTableViewDataSource()
        self.tableViewDelegate = CartListTableViewDelegate()
        super.init(nibName: .None, bundle: .None)
        self.tableViewDelegate.windowObserver = self.windowObserver
        self.tableViewDataSource.controller = self
        self.tableViewDelegate.controller = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add in my custom view
        self.view.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        
        // configure my view and add in the custom view
        self.contentView.configureViewWithController(self, tableViewDataSource: self.tableViewDataSource, tableViewDelegate: self.tableViewDelegate)
        
        // register for data source changes
        self.contentModel.cartfileObserver.add(self, self.dynamicType.modelDidChange)
        
        // configure the tableview for dragging
        self.contentView.registerTableViewForDraggedTypes(PUBLIC_TEXT_TYPES)
        
        // configure default cellHeight
        self.contentView.updateTableViewRowHeight(32)
        
        // register for table selection observing
        self.windowObserver.tableViewRowSelectedStateObserver.add(self, self.dynamicType.tableViewSelectionChangedToIndexes)
        
        // register for notifications on window resize
        if let parentWindowController = self.parentWindowController {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeSize:", name: NSWindowDidEndLiveResizeNotification, object: parentWindowController.window)
        }
        
        // reload the data table
        self.contentView.reloadTableViewData()
    }
    
    // MARK: Data Source Observing
    
    func modelDidChange() {
        self.contentView.reloadTableViewData()
    }
    
    // MARK: Handle window resizing
    
    @objc private func windowDidChangeSize(notification: NSNotification) {
        self.contentView.noteHeightOfVisibleRowsChanged()
    }
    
    // MARK: Handle Table View Selection Changing
    
    private func tableViewSelectionChangedToIndexes(indexes: [Range<Int>]) {
        if indexes.isEmpty == true {
            self.contentView.deleteButtonEnabled = false
        } else {
            self.contentView.deleteButtonEnabled = true
        }
    }
    
    // MARK: Handle Add / Delete Button Presses
    
    @objc private func didClickDeleteButton(sender: NSButton) {
        // don't do anything if no rows are selected
        if self.contentView.tableViewSelectedRowIndexes.isEmpty == false {
            
            enum DeleteCartfilesAlertResponse: Int {
                case RemoveButton = 1000
                case CancelButton = 1001
            }
            // TODO: Convert this to NSPopover because its nicer :)
            let alert = NSAlert()
            alert.addButtonWithTitle("Remove")
            alert.addButtonWithTitle("Cancel")
            alert.messageText = NSLocalizedString("Remove Selected Cartfiles?", comment: "Description for alert that is shown when the user tries to delete Cartfiles from the main list")
            alert.alertStyle = NSAlertStyle.WarningAlertStyle
            alert.beginSheetModalForWindow(self.window!) { untypedResponse -> Void in
                if let response = DeleteCartfilesAlertResponse(rawValue: Int(untypedResponse.value)) {
                    switch response {
                    case .RemoveButton:
                        self.contentModel.removeCartfilesAtIndexes(self.contentView.tableViewSelectedRowIndexes)
                    case .CancelButton:
                        self.log.info("User chose delete button but then cancelled the operation.")
                    }
                }
            }
        }
    }
    
    // MARK: EventPassingButtonDelegate
    
    func didClickDownOnEventPassingButton(sender: CWEventPassingButton, theEvent: NSEvent) {
        
        let menu = NSMenu(title: "Testing123")
        menu.addItemWithTitle("First Item", action: "firstItem:", keyEquivalent: "")
        menu.addItemWithTitle("Second Item", action: "secondItem:", keyEquivalent: "")
        NSMenu.popUpContextMenu(menu, withEvent: theEvent, forView: sender)
        
//        let fileChooser = NSOpenPanel()
//        fileChooser.canChooseFiles = true
//        fileChooser.canChooseDirectories = true
//        fileChooser.allowsMultipleSelection = true
//        
//        fileChooser.beginSheetModalForWindow(self.window!) { untypedResult in
//            let result = NSFileHandlingPanelResponse(rawValue: untypedResult)!
//            switch result {
//            case .SuccessButton:
//                if let cartfiles = CWCartfile.cartfilesFromURL(fileChooser.URLs) {
//                    self.contentModel.appendCartfiles(cartfiles)
//                }
//            case .CancelButton:
//                self.log.info("File Chooser was cancelled by user.")
//            }
//        }
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
                        let cartfile = CWCartfile(url: cartfileWriteResult.finalURL)
                        self.contentModel.appendCartfile(cartfile)
                        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([cartfile.url])
                    }
                }
            case .CancelButton:
                self.log.info("CartListViewController: File Saver was cancelled by user.")
            }
        })
        self.savePanel = savePanel // this allows us to hack the save panel with the hacky code under NSOpenSavePanelDelegate.
    }
    
    // MARK: Handle Dragging
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        pboard.declareTypes(PUBLIC_TEXT_TYPES, owner: self)
        pboard.writeObjects([CWIndexSetPasteboardContainer(indexSet: rowIndexes)])
        return true
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        tableView.deselectAll(self)
        self.tableViewIsDragging = false
        
        let activity = self.pasteboardActivity(info.draggingPasteboard(), quickMode: false)
        switch activity {
        case .DragFile(let url):
            if let draggedCartfiles = CWCartfile.cartfilesFromURL(url) {
                self.contentModel.insertCartfiles(draggedCartfiles, atIndex: row)
                return true
            } else {
                return false
            }
        case .MoveRow(let indexes):
            self.contentModel.moveCartfilesAtIndexes(indexes, toIndex: row)
            return true
        case .Unknown:
            return false
        }
    }

    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        tableView.deselectAll(self)
        self.tableViewIsDragging = true
        let activity = self.pasteboardActivity(info.draggingPasteboard(), quickMode: true)
        switch activity {
        case .DragFile(let url):
            return NSDragOperation.Copy
        case .MoveRow(let indexes):
            return NSDragOperation.Move
        case .Unknown:
            return NSDragOperation.Generic
        }
    }
    
    // This lets us notify the cells when we are dragging so they can adjust their drawing style
    // Basically, the cells were showing a selected style when dragging a single cell over them
    private let tableViewIsDraggingObserver = ObserverSet<Bool>()
    private var tableViewIsDragging = false {
        didSet {
            self.tableViewIsDraggingObserver.notify(self.tableViewIsDragging)
        }
    }
    
    private enum PasteboardActivity {
        case DragFile(URLs: [NSURL])
        case MoveRow(indexSet: NSIndexSet)
        case Unknown
    }
    
    private func pasteboardActivity(pasteboard: NSPasteboard?, quickMode: Bool) -> PasteboardActivity {
        // verify there is a pasteboard
        if let pasteboard = pasteboard {
            // first we check for URLs. There is a fast and slow way to do this
            // Fast way returns only the first URL from the pasteboard
            // Slow way returns an array of all the URLs in the pasteboard
            if quickMode == true {
                if let url = NSURL(fromPasteboard: pasteboard) { return .DragFile(URLs: [url]) }
            } else {
                if let URLs = NSURL.URLsFromPasteboard(pasteboard) { return .DragFile(URLs: URLs) }
            }
            
            // If those fail, then we are not dragging a URL, it is probably a row
            if let items = pasteboard.readObjectsForClasses([CWIndexSetPasteboardContainer.self], options: nil),
                let indexes = (items.first as? CWIndexSetPasteboardContainer)?.containedIndexSet {
                    return .MoveRow(indexSet: indexes)
            }
        }
        // If all that fails, we are dragging something unknown
        self.log.info("Unknown item found in pasteboard: \(pasteboard)")
        return .Unknown
    }

    // MARK: Handle going away
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
// NOTE: This silently fails when using Sandboxing. Apple replaces the savepanel like "magic"
//

extension CartListTableViewController: NSOpenSavePanelDelegate {
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
