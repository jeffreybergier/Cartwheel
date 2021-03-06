//
//  DependencyDefinableListTableCellView.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/22/15.
//
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

final class CartfileTableCellView: NSTableCellView {
    var controller: CartfileTableCellViewController?
    
    static let identifier = "CartfileTableCellView"
    override var identifier: String? {
        get { return self.classForCoder.identifier }
        set { /* do nothing */ /* this setter is needed to please the compiler */ }
    }
}

final class PodfileTableCellView: NSTableCellView {
    var controller: PodfileTableCellViewController?
    
    static let identifier = "PodfileTableCellView"
    override var identifier: String? {
        get { return self.classForCoder.identifier }
        set { /* do nothing */ /* this setter is needed to please the compiler */ }
    }
}