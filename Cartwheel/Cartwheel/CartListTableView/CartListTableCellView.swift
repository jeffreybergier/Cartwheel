//
//  CartListTableCellView.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/28/15.
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

class CartListTableCellView: NSView {
    
    let ui = interfaceView()
    
    func viewDidLoad() {
        self.wantsLayer = true
        
        self.addSubview(self.ui.primaryTextField)
        self.configureTestLabel()
    }
    
    private func configureTestLabel() {
        if self.ui.primaryTextField.superview != nil {
            self.ui.primaryTextField.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
            self.ui.primaryTextField.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
            self.ui.primaryTextField.bordered = true //change to false later
            (self.ui.primaryTextField.cell() as? NSTextFieldCell)?.drawsBackground = false
            self.ui.primaryTextField.editable = false
            self.ui.primaryTextField.stringValue = "Hello There"
        } else {
            fatalError("CartListTableCellView: Tried to configure test label before it was in the view hierarchy.")
        }
    }
    
    struct interfaceView {
        var primaryTextField = NSTextField()
    }
    
}
