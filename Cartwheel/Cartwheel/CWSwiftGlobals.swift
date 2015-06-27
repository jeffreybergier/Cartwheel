//
//  CWSwiftGlobals.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 5/10/15.
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

import AppKit

// MARK: Fixing Broken AppKit Stuff

struct CWLayoutPriority {
    static var Required: NSLayoutPriority = 1000
    static var DefaultHigh: NSLayoutPriority = 750
    static var DragThatCanResizeWindow: NSLayoutPriority = 510
    static var WindowSizeStayPut: NSLayoutPriority = 500
    static var DragThatCannotResizeWindow: NSLayoutPriority = 490
    static var DefaultLow: NSLayoutPriority = 250
    static var FittingSizeCompression: NSLayoutPriority = 50
}

extension NSView {
    func writeScreenShotToDiskWithName(name: String) -> NSError? {
        // Capture original invisibility state
        let originalHiddenState = self.hidden
        let originalAlphaState = self.alphaValue
        
        // change view to be fully visible for screenshot
        self.hidden = false
        self.alphaValue = 1.0
        
        // create URL in App Support directory
        let appSupport = (NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).last as! String) + "/Cartwheel"
        let appSupportURL = NSURL(fileURLWithPath: appSupport, isDirectory: true)
        let screenshotFileURL = appSupportURL!.URLByAppendingPathComponent(name + ".tiff")
        
        // capture screenshot
        let screenshot = NSImage(data: self.dataWithPDFInsideRect(self.bounds))
        
        // save to disk
        var error: NSError?
        screenshot?.TIFFRepresentation?.writeToURL(screenshotFileURL, options: NSDataWritingOptions.AtomicWrite, error: &error)
        
        // Restore invisiblity state
        self.hidden = originalHiddenState
        self.alphaValue = originalAlphaState
        
        // return error (if any)
        return error
    }
}

// MARK: NSURL == CWCartfile

// The cartfile type built into carthage kit can be created with a URL
// but it doesn't store that URL as a property
// this makes it hard to serialized and deserialized from disk
// In the meantime, I'll just store NSURL's on disk 
// but use a typealias so i know they should be Cartfile URL's

typealias CWCartfile = NSURL

// MARK: Extensions of Built in Types

extension Array {
    static func filterOptionals(array: [T?]) -> [T] {
        return array.filter { $0 != nil }.map { $0! }
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return index < count && index >= 0 ? self[index] : nil
    }
    
    subscript (unsafe index: Int) -> Element {
        return self[index]
    }
    
    subscript (yolo index: Int) -> Element { // YOLO! Crashes if out of range
        return self[index]
    }
}

extension Set {
    func map<U>(transform: (T) -> U) -> Set<U> {
        return Set<U>(Swift.map(self, transform))
    }
}

// MARK: Custom Enums

enum NSFileHandlingPanelResponse: Int {
    case CancelButton = 0, OKButton
}

extension NSFileHandlingPanelResponse: Printable {
    var description: String {
        switch self {
        case CancelButton:
            return "NSFileHandlingPanelResponse.CancelButton"
        case OKButton:
            return "NSFileHandlingPanelResponse.OKButton"
        }
    }
}

// MARK: Operator Overloads

infix operator !! { associativity right precedence 110 }
// AssertingNilCoalescing operator crashes when LHS is nil when App is in Debug Build.
// When App is in release build, it performs ?? operator
// Crediting http://blog.human-friendly.com/theanswer-equals-maybeanswer-or-a-good-alternative
public func !!<A>(lhs:A?, @autoclosure rhs:()->A)->A {
    assert(lhs != nil)
    return lhs ?? rhs()
}