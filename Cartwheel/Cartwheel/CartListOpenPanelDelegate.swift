//
//  CartListOpenPanelDelegate.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/1/15.
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

class CartListOpenPanelDelegate: NSObject, NSOpenSavePanelDelegate {
    
    private let log = XCGLogger.defaultInstance()
    
    func presentAddCartfilesFileChooserWithinWindow(window: NSWindow, modifyContentModel contentModel: CWCartfileDataSource) {
        let fileChooser = NSOpenPanel()
        fileChooser.canChooseFiles = true
        fileChooser.canChooseDirectories = true
        fileChooser.allowsMultipleSelection = true
        fileChooser.title = NSLocalizedString("Add Cartfiles", comment: "Title of add cartfiles open panel")
        
        fileChooser.beginSheetModalForWindow(window) { untypedResult in
            let result = NSFileHandlingPanelResponse(rawValue: untypedResult)!
            switch result {
            case .SuccessButton:
                if let cartfiles = CWCartfile.cartfilesFromURL(fileChooser.URLs) {
                    contentModel.appendCartfiles(cartfiles)
                }
            case .CancelButton:
                self.log.info("File Chooser was cancelled by user.")
            }
        }
    }
    
    func presentCreateBlankCartfileFileChooserWithinWindow(window: NSWindow, modifyContentModel contentModel: CWCartfileDataSource) {
        let savePanel = NSOpenPanel()
        savePanel.delegate = self
        savePanel.canChooseDirectories = true
        savePanel.canCreateDirectories = true
        savePanel.canChooseFiles = false
        savePanel.allowsMultipleSelection = false
        savePanel.title = NSLocalizedString("Create New Cartfile", comment: "Title of the create new cartfile save dialog.")
        savePanel.prompt = self.savePanelOriginalButtonTitle
        savePanel.beginSheetModalForWindow(window, completionHandler: { untypedResult in
            let result = NSFileHandlingPanelResponse(rawValue: untypedResult)!
            switch result {
            case .SuccessButton:
                if let selectedURL = savePanel.URL {
                    let cartfileWriteResult = contentModel.writeBlankCartfileToDirectoryPath(selectedURL)
                    if let error = cartfileWriteResult.error {
                        let alert = NSAlert(error: error)
                        savePanel.orderOut(nil) // TODO: try to remove this later. Its not supposed to be needed.
                        alert.beginSheetModalForWindow(window, completionHandler: nil)
                        self.log.error("\(error)")
                    } else {
                        let cartfile = CWCartfile(url: cartfileWriteResult.finalURL)
                        contentModel.appendCartfile(cartfile)
                        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([cartfile.url])
                    }
                }
            case .CancelButton:
                self.log.info("CartListViewController: File Saver was cancelled by user.")
            }
        })
        self.savePanel = savePanel // this allows us to hack the save panel with the hacky code under NSOpenSavePanelDelegate.
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
    
    private var savePanelShouldOpenURL: NSURL?
    private var savePanelDidChangeToDirectoryURL: NSURL?
    private weak var savePanel: NSOpenPanel?
    private let savePanelOriginalButtonTitle = NSLocalizedString("Create Cartfile", comment: "In the save sheet for creating a new cartifle, this button is the create new button")
    
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
