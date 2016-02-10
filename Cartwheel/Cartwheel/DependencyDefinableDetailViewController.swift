//
//  DependencyDefinableDetailViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 2/8/16.
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

class DependencyDefinableDetailViewController: NSViewController {
    
    var content: DependencyDefinable? {
        didSet {
            self.updateUIWithDependencyDefinable(self.content)
        }
    }
    
    @IBOutlet private weak var titleLabel: NSTextField?
    @IBOutlet private weak var fileContentsLabel: NSTextField?
    @IBOutlet private weak var updateButton: NSButton?
    @IBOutlet private weak var progressIndicator: NSProgressIndicator?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateUIWithDependencyDefinable(.None)
    }
    
    private func updateUIWithDependencyDefinable(dd: DependencyDefinable?) {
        // Always do the following when changing DD
        self.progressIndicator?.indeterminate = true
        self.progressIndicator?.stopAnimation(self)
        
        if let dd = dd {
            self.titleLabel?.stringValue = dd.title
            self.updateButton?.enabled = true
            self.fileContentsLabel?.stringValue = (try? self.stringContentsOfDependencyDefinable(dd)) ?? "ERROR Reading File"
            self.updateButton?.hidden = false
            self.progressIndicator?.hidden = false
        } else {
            self.titleLabel?.stringValue = ""
            self.updateButton?.enabled = false
            self.fileContentsLabel?.stringValue = ""
            self.updateButton?.hidden = true
            self.progressIndicator?.hidden = true
        }
    }
    
    @IBAction private func updateButtonClicked(sender: NSButton?) {
        print("Update button clicked")
    }
    
    private func stringContentsOfDependencyDefinable(dd: DependencyDefinable) throws -> String {
        do {
            let fileContents = try NSString(contentsOfURL: dd.url, encoding: NSUTF8StringEncoding)
            return fileContents as String
        } catch {
            throw error
        }
    }
}