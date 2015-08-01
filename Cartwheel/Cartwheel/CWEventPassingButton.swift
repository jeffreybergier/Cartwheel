//
//  CWPopUpMenuButton.swift
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

protocol EventPassingButtonDelegate: NSObjectProtocol {
    func didClickDownOnEventPassingButton(sender: CWEventPassingButton, theEvent: NSEvent)
}

// This button ignores the target and action set on it.
// Instead it always sends the mouseDown event to its delegate

class CWEventPassingButton: NSButton {
    
    // TODO: Find a way to actually override the type in target so to get better type safety
    override var target: AnyObject? {
        get { return self.eventPassingTarget }
        set { if let verifiedTarget = newValue as? EventPassingButtonDelegate { self.eventPassingTarget = verifiedTarget }
            else {
                XCGLogger.defaultInstance().severe("tried to assign target to object that does not conform to protocol: EventPassingButtonDelegate")
                self.eventPassingTarget = .None
            }}
    }
    private var eventPassingTarget: EventPassingButtonDelegate?

    override var action: Selector {
        get { return nil }
        set { }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let target = eventPassingTarget {
            target.didClickDownOnEventPassingButton(self, theEvent: theEvent)
        } else {
            super.mouseDown(theEvent)
        }
    }
    
}
