//
// CartListWindowController.swift
// Cartwheel
//
// Created by Jeffrey Bergier on 4/9/15.
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Cocoa
//import PureLayout_Mac

class CartListWindowController: NSWindowController {
    
    let viewController: CartListViewController
    
    override init() {
        let styleMask: Int = NSTitledWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask | NSResizableWindowMask //| NSFullScreenWindowMask
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 400), styleMask: styleMask, backing: NSBackingStoreType.Buffered, defer: true)
        
        self.viewController = CartListViewController()
        
        super.init(window: window)
        self.viewController.window = window
        self.window?.contentView = self.viewController.view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}