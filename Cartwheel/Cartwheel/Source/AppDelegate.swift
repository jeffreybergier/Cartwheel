//
//  AppDelegate.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/27/15.
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

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var cartListWindowController: CartListWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        XCGLogger.defaultInstance().setup(logLevel: .Verbose, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: .Warning)
        
        self.cartListWindowController = CartListWindowController()
        self.cartListWindowController!.showWindow(self) // should crash if NIL at this point
        
        self.cartListWindowController?.windowObserver?.windowDidCloseObserver.add(self, self.dynamicType.cartListWindowControllerDidClose)
    }
    
    private func cartListWindowControllerDidClose() {
        self.cartListWindowController = nil // this allows the window to be deallocated
    }
}
