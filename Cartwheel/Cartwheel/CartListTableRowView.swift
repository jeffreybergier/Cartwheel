//
//  CartListTableRowView.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 6/30/15.
//  Copyright (c) 2015 Saturday Apps. All rights reserved.
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

class CartListTableRowView: NSTableRowView {
    
    weak var cellViewController: CartListTableCellViewController?
    
    // MARK: Handle Intialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.wantsLayer = true
    }
    
    // MARK: Handle Selecting a Row
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
        super.drawSelectionInRect(dirtyRect)
    }
    
    // MARK: Handle Line Separators
    
    override func drawSeparatorInRect(dirtyRect: NSRect) {
        super.drawSeparatorInRect(dirtyRect)
    }
    
    // MARK: Handle Mouse Hover Events
    
    private var mouseInView = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    // Implementing a tracking area is required for mouseEntering and mouseExiting events
    private lazy var trackingArea: NSTrackingArea = NSTrackingArea(rect: NSRect.zeroRect, options: .InVisibleRect | .ActiveAlways | .MouseEnteredAndExited, owner: self, userInfo: nil)
    
    override func drawBackgroundInRect(dirtyRect: NSRect) {
        super.drawBackgroundInRect(dirtyRect)
        if self.mouseInView == true {
            self.cellViewController?.didHighlight()
        } else {
            self.cellViewController?.didDehighlight()
        }
    }
    
    override func updateTrackingAreas() {
        // setting the tracking areas is required for mouseEntered and mouseExited to be called
        super.updateTrackingAreas()
        if (self.trackingAreas as NSArray).containsObject(trackingArea) == false {
            self.addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        self.mouseInView = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        self.mouseInView = false
    }
}

// MARK: Handle Printable

extension CartListTableRowView: Printable {
    override var description: String {
        if let cartfileURL = self.cellViewController?.cartfileURL,
            let pathComponents = cartfileURL.pathComponents,
            let containingFolder = pathComponents[pathComponents.count - 2] as? String {
                return "CartListTableRowView for Cell with Cartfile Named: \(containingFolder)"
        }
        return super.description
    }
}