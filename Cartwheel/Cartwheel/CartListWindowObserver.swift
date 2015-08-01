//
//  CartListWindowObserver.swift
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
import ObserverSet

protocol WindowMainStateObserver {
    var windowMainStateObserver: ObserverSet<Bool> { get }
}

protocol TableViewRowSelectedStateObserver {
    var tableViewRowSelectedStateObserver: ObserverSet<[Range<Int>]> { get }
}

protocol TableViewRowIsDraggingObserver {
    var tableViewRowIsDraggingObserver: ObserverSet<Bool> { get }
}

protocol WindowDidChangeFrameObserver {
    var windowDidChangeFrameObserver: ObserverSet<NSRect?> { get }
}

protocol WindowDidCloseObserver {
    var windowDidCloseObserver: ObserverSet<Void> { get }
}

class CartListWindowObserver:
    WindowMainStateObserver,
    TableViewRowSelectedStateObserver,
    TableViewRowIsDraggingObserver,
    WindowDidChangeFrameObserver,
    WindowDidCloseObserver
    
{
    
    init(windowToObserve: NSWindow?) {
        if let window = windowToObserve {
            // register for notifications
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidBecomeMain:", name: NSWindowDidBecomeMainNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidResignMain:", name: NSWindowDidResignMainNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeFrame:", name: NSWindowDidEndLiveResizeNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidChangeFrame:", name: NSWindowDidMoveNotification, object: window)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidClose:", name: NSWindowWillCloseNotification, object: window)
        }
    }
    
    // MARK: WindowMainObserver Protocol
    
    var windowMainStateObserver = ObserverSet<Bool>()
    
    @objc private func windowDidBecomeMain(notification: NSNotification) {
        self.windowMainStateObserver.notify(true)
    }
    @objc private func windowDidResignMain(notification: NSNotification) {
        self.windowMainStateObserver.notify(false)
    }
    
    // MARK: TableViewRowSelectedStateObserver Protocol
    
    let tableViewRowSelectedStateObserver = ObserverSet<[Range<Int>]>()
    
    // MARK: TableViewRowIsDraggingObserver Protocol
    
    let tableViewRowIsDraggingObserver = ObserverSet<Bool>()
    
    // MARK: WindowDidChangeSizeObserver Protocol
    
    let windowDidChangeFrameObserver = ObserverSet<NSRect?>()
    
    @objc private func windowDidChangeFrame(notification: NSNotification) {
        let frame = (notification.object as? NSWindow)?.frame
        self.windowDidChangeFrameObserver.notify(frame)
    }
    
    // MARK: WindowDidCloseObserver
    
    var windowDidCloseObserver = ObserverSet<Void>()
    
    @objc private func windowDidClose(notification: NSNotification) {
        self.windowDidCloseObserver.notify()
    }
    
    // MARK: Handle Going Away
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
