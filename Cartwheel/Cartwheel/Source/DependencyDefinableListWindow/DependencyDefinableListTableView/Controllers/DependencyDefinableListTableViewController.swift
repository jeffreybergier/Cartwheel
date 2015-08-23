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

protocol DependencyDefinablesControllable: class {
    var dependencyDefinables: [DependencyDefinable]? { get set }
}

@objc(DependencyDefinableListTableViewController)
final class DependencyDefinableListTableViewController: NSViewController, DependencyDefinableListModelControllable, DependencyDefinablesControllable, CartfileWindowControllable {
    
    // Model Object
    let dataSource: DependencyDefinableListModel
    var dependencyDefinables: [DependencyDefinable]? {
        didSet {
            self.contentView.tableView.reloadData()
        }
    }
    
    // View Object
    private let contentView = DependencyDefinableListView()
    
    // Parent Controller
    var window: NSWindow? {
        return self.parentWindowController?.window
    }
    private weak var parentWindowController: NSWindowController?
    
    // Window Observer
    let windowObserver: DependencyDefinableListWindowObserver
    
    // Logging Object
    private let log = XCGLogger.defaultInstance()
    
    // Child Controllers
    private let tableViewDataSource = DependencyDefinableListTableViewDataSource()
    private let tableViewDelegate = DependencyDefinableListTableViewDelegate()
    private let searchFieldDelegate = DependencyDefinableListSearchFieldDelegate()
    private let toolbarController = DependencyDefinableListWindowToolbarController()
    
    // MARK: Init
    
    init!(controller: NSWindowController, model: DependencyDefinableListModel, windowObserver: DependencyDefinableListWindowObserver) {
        self.dataSource = model
        self.dependencyDefinables = model.dependencyDefinables // set the cartfiles on init. After init, the cartfiles will update themselves via SwiftObserver
        self.parentWindowController = controller
        self.windowObserver = windowObserver
        super.init(nibName: .None, bundle: .None)
        self.tableViewDelegate.windowObserver = self.windowObserver
        self.searchFieldDelegate.windowObserver = self.windowObserver
        self.tableViewDataSource.windowObserver = self.windowObserver
        self.toolbarController.searchFieldDelegate = self.searchFieldDelegate
        self.tableViewDataSource.searchFieldDelegate = self.searchFieldDelegate
        self.searchFieldDelegate.controller = self
        self.tableViewDataSource.controller = self
        self.tableViewDelegate.controller = self
        self.toolbarController.controller = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the window's toolbar
        self.window?.toolbar = self.toolbarController.toolbar
        
        // add in my custom view
        self.view.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        
        // register for data source changes
        self.dataSource.modelObserver.add(self, self.dynamicType.contentModelDidChange)
        
        // register for search delegate observing
        self.searchFieldDelegate.windowObserver!.searchDelegateObserver.add(self, self.dynamicType.searchResultedInFilteredCartfiles)
        
        // configure the tableview for dragging
        self.contentView.tableView.registerForDraggedTypes(self.tableViewDataSource.PUBLIC_TEXT_TYPES)
        
        // configure default cellHeight
        self.contentView.tableView.rowHeight = 32
        
        // register for table selection observing
        self.windowObserver.tableViewRowSelectedStateObserver.add(self, self.dynamicType.tableViewSelectionChangedToIndexes)
        
        // configure my view and add in the custom view
        self.contentView.configureViewWithController(self, tableViewDataSource: self.tableViewDataSource, tableViewDelegate: self.tableViewDelegate)
        
        // register for notifications on window resize
        self.windowObserver.windowDidChangeFrameObserver.add(self, self.dynamicType.windowDidChangeFrame)
        
        // reload the data table
        self.contentView.tableView.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let adjustedContentInset = NSEdgeInsets(top: self.contentView.scrollView.contentInsets.top, left: self.contentView.scrollView.contentInsets.left, bottom: self.contentView.addButton.frame.size.height, right: self.contentView.scrollView.contentInsets.right)
        // WARNING: Turning this off could cause bugs if the toolbar resizes
        self.contentView.scrollView.automaticallyAdjustsContentInsets = false
        self.contentView.scrollView.contentInsets = adjustedContentInset
    }
}

// MARK: Handle Content and State Changing

extension DependencyDefinableListTableViewController {
    // Data Source Observing
    private func contentModelDidChange() {
        if self.searchFieldDelegate.searchInProgress == false {
            self.dependencyDefinables = self.dataSource.dependencyDefinables
        }
    }
    
    // Search Delegate Observing
    private func searchResultedInFilteredCartfiles(filteredCartfiles: [DependencyDefinable]?) {
        if let filteredCartfiles = filteredCartfiles {
            self.dependencyDefinables = filteredCartfiles
        } else {
            self.contentModelDidChange()
        }
    }
    
    // Handle window resizing
    private func windowDidChangeFrame(newFrame: NSRect?) {
        self.contentView.noteHeightOfVisibleRowsChanged()
    }
    
    // Handle Table Row Selection
    private func tableViewSelectionChangedToIndexes(indexes: [Range<Int>]) {
        if indexes.isEmpty == true {
            self.contentView.deleteButton.enabled = false
        } else {
            self.contentView.deleteButton.enabled = true
        }
    }
}

// MARK: Handle Add / Delete Buttons

extension DependencyDefinableListTableViewController {
    @objc private func didClickDeleteButton(sender: NSButton) {
        // don't do anything if no rows are selected
        let selectedIndexes = self.contentView.tableView.selectedRowIndexes.ranges
        if selectedIndexes.isEmpty == false {
            let alert = NSAlert(style: .CartfileRemoveConfirm)
            alert.beginSheetModalForWindow(self.window!) { untypedResponse -> Void in
                if let response = NSAlert.Style.CartfileRemoveConfirmResponse(rawValue: Int(untypedResponse.value)) {
                    switch response {
                    case .RemoveButton:
                        self.dataSource.removeDependencyDefinablesAtIndexes(self.contentView.tableView.selectedRowIndexes.ranges)
                    case .CancelButton:
                        self.log.info("User chose delete button but then cancelled the operation.")
                    }
                }
            }
        }
    }
    
    private func didClickAddButton(sender: EventPassingButton, theEvent: NSEvent) {
        let menu = NSMenu(title: "Testing123")
        menu.delegate = self
        menu.addItemWithTitle(NSLocalizedString("Add Cartfiles", comment: "Title of add cartfiles open panel"), action: "didChooseAddCartfilesMenuItem:", keyEquivalent: "")
        menu.addItemWithTitle(NSLocalizedString("Create New Cartfile", comment: "Title of the create new cartfile save dialog."), action: "didChooseCreateBlankCartfileMenuItem:", keyEquivalent: "")
        NSMenu.popUpContextMenu(menu, withEvent: theEvent, forView: sender)
    }
}

// MARK: NSMenuDelegate

extension DependencyDefinableListTableViewController: NSMenuDelegate {
    @objc private func didChooseAddCartfilesMenuItem(sender: NSMenuItem) {
        let savePanel = NSOpenPanel(style: .AddCartfiles)
        savePanel.beginSheetModalForWindow(self.window!) { untypedResult in
            let result = NSOpenPanel.Response(rawValue: untypedResult)!
            switch result {
            case .SuccessButton:
                if let dependencyDefinables = DependencyDefinableType.fromURLs(savePanel.URLs) {
                    self.dataSource.appendDependencyDefinables(dependencyDefinables)
                }
            case .CancelButton:
                self.log.info("File Chooser was cancelled by user.")
            }
        }
    }
    @objc private func didChooseCreateBlankCartfileMenuItem(sender: NSMenuItem) {
        let delegate = CartListOpenPanelDelegate()
        let savePanel = NSOpenPanel(style: .CreatBlankCartfile(delegate: delegate))
        delegate.savePanel = savePanel
        savePanel.beginSheetModalForWindow(self.window!, completionHandler: { untypedResult in
            if let result = NSOpenPanel.Response(rawValue: untypedResult) {
                switch result {
                case .SuccessButton:
                    if let selectedURL = savePanel.URL {
                        let cartfileWriteResult = Cartfile.writeEmptyToDirectory(selectedURL)
                        if let error = cartfileWriteResult {
                            let alert = NSAlert(error: error)
                            savePanel.orderOut(nil) // TODO: try to remove this later. Its not supposed to be needed.
                            alert.beginSheetModalForWindow(self.window!, completionHandler: nil)
                            self.log.error("\(error)")
                        } else {
                            if let cartfile = Cartfile(location: selectedURL) {
                                self.dataSource.appendDependencyDefinable(cartfile)
                                let cartfileURL = cartfile.location.URLByAppendingPathComponent(Cartfile.fileName())
                                NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([cartfileURL])
                            }
                        }
                    }
                case .CancelButton:
                    self.log.info("CartListViewController: File Saver was cancelled by user.")
                }
            }
            delegate.savePanel = nil // this captures the delegate and retains it until the end of the of completion handler
        })
    }
}

// MARK: EventPassingButtonDelegate

extension DependencyDefinableListTableViewController: EventPassingButtonDelegate {
    func didClickDownOnEventPassingButton(sender: EventPassingButton, theEvent: NSEvent) {
        self.didClickAddButton(sender, theEvent: theEvent)
    }
}