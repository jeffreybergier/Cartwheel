//
//  CartListTableCellViewController.swift
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
import CarthageKit

class CartListTableCellViewController: NSTableCellView {
    
    private let contentView = CartListTableCellView()
    var isLastCell = false {
        didSet {
            self.contentView.isLastCell = self.isLastCell
        }
    }
    
    var cartfileURL: CWCartfile? {
        didSet {
            self.prepareCellForNewModelObject()
            self.updateCellWithNewModelObject()
        }
    }
    
    private func prepareCellForNewModelObject() {
        
    }
    
    private func updateCellWithNewModelObject() {
        if let cartfileURL = self.cartfileURL,
            let pathComponents = cartfileURL.pathComponents,
            let containingFolder = pathComponents[pathComponents.count - 2] as? String {
                self.contentView.ui.cartfileTitleLabel.stringValue = containingFolder
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(self.contentView)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        self.contentView.viewDidLoad()
    }
    
    func cellWasDeselected() {
        println("\(self) was de-selected")
    }
    
    func cellWasSelected() {
        println("\(self) was selected")
    }
    
    func cellWasHighlighted() {
        println("\(self) was highlighted")
    }
    
}

extension CartListTableCellViewController: Printable {
    override var description: String {
        return "CartListTableCellViewController \(self.contentView.ui.cartfileTitleLabel.stringValue):"
    }
}
