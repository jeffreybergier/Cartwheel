//
//  CartListAlertController.swift
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

class CartListAlertController {
    
    private let log = XCGLogger.defaultInstance()
    
    func presentAlertConfirmDeleteIndexes(indexes: [Range<Int>], fromContentModel contentModel: CWCartfileDataSource, withinWindow window: NSWindow) {
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
        alert.beginSheetModalForWindow(window) { untypedResponse -> Void in
            if let response = DeleteCartfilesAlertResponse(rawValue: Int(untypedResponse.value)) {
                switch response {
                case .RemoveButton:
                    contentModel.removeCartfilesAtIndexes(indexes)
                case .CancelButton:
                    self.log.info("User chose delete button but then cancelled the operation.")
                }
            }
        }
    }
}
