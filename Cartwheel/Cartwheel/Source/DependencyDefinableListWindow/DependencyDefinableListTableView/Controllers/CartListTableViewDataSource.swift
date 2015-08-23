//
//  CartListTableViewDataSource.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/31/15.
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

class DependencyDefinableListTableViewDataSource: DependencyDefinableListChildController, NSTableViewDataSource {
    
    // MARK: NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        // return the actual number of rows
        return self.controller?.dependencyDefinables?.count ?? 0
    }
    
    // MARK: SearchFieldDelegate
    // we need to reference the search field delegate so we can reject drags when the table is being searched
    
    weak var searchFieldDelegate: SearchInProgressControllable?
    
    // MARK: Handle Dragging
    
    let PUBLIC_TEXT_TYPES = [NSFilenamesPboardType]
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        /* #guard-search */if self.searchFieldDelegate?.searchInProgress == true { return false }

        pboard.declareTypes(PUBLIC_TEXT_TYPES, owner: self)
        pboard.writeObjects([CWIndexSetPasteboardContainer(indexSet: rowIndexes)])
        return true
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        /* #guard-search */if self.searchFieldDelegate?.searchInProgress == true { return false }
        
        tableView.deselectAll(self)
        self.windowObserver?.tableViewRowIsDraggingObserver.notify(false)
        
        let activity = self.pasteboardActivity(info.draggingPasteboard(), quickMode: false)
        switch activity {
        case .DragFile(let url):
            if let draggedDDs = DependencyDefinableType.fromURLs(url) {
                self.controller?.dataSource.insertDependencyDefinables(draggedDDs, atIndex: row)
                return true
            } else {
                return false
            }
        case .MoveRow(let indexes):
            self.controller?.dataSource.moveDependencyDefinablesAtIndexes(indexes, toIndex: row)
            return true
        case .Unknown:
            return false
        }
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        /* #guard-search */if self.searchFieldDelegate?.searchInProgress == true { return NSDragOperation.None }
        
        tableView.deselectAll(self)
        self.windowObserver?.tableViewRowIsDraggingObserver.notify(true)
        
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
}

extension DependencyDefinableListTableViewDataSource {
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
        XCGLogger.defaultInstance().info("Unknown item found in pasteboard: \(pasteboard)")
        return .Unknown
    }
}

