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

// MARK: Extending NSURL

extension NSURL {
    
    func extractFilesRecursionDepth(recursionDepth: Int) -> [NSURL]? {
        let files = self.recurseFilesByEnumeratingURLWithInitialURLs([NSURL](), maxDepth: recursionDepth, currentDepth: 0)
        if files.count > 0 { return files } else { return .None }
    }
    
    private func recurseFilesByEnumeratingURLWithInitialURLs(startingFiles: [NSURL], maxDepth: Int, currentDepth: Int) -> [NSURL] {
        let files: [NSURL]
        if let filesAndDirectories = self.filesAndDirectories() where currentDepth <= maxDepth {
            let recursionFiles = filesAndDirectories.remainingDirectories.map { directory -> [NSURL] in
                return directory.recurseFilesByEnumeratingURLWithInitialURLs(startingFiles, maxDepth: maxDepth, currentDepth: currentDepth + 1)
            }
            let mergedRecursionFiles = Array.merge(recursionFiles)
            files = startingFiles + filesAndDirectories.files + mergedRecursionFiles
        } else {
            files = startingFiles
        }
        return files
    }
    
    func filesAndDirectories() -> URLEnumeration? {
        let fileManager = NSFileManager.defaultManager()
        let defaultsPlist = CWDefaultsPlist()
        
        let urlKeys = [NSURLIsDirectoryKey]
        let enumeratorOptions: NSDirectoryEnumerationOptions = .SkipsHiddenFiles | .SkipsPackageDescendants | .SkipsSubdirectoryDescendants
        
        let enumerator = fileManager.enumeratorAtURL(self, includingPropertiesForKeys: urlKeys, options: enumeratorOptions) {
            (url: NSURL?, error: NSError?) -> Bool in
            NSLog("CartListViewController: NSEnumerator Error: \(error) with URL: \(url)")
            return true
        }
        
        if let enumeratorObjects = enumerator?.allObjects {
            let optionalFiles = enumeratorObjects.map { object -> NSURL? in
                if let url = object as? NSURL,
                    let urlResources = url.resourceValuesForKeys(urlKeys, error: nil),
                    let urlIsDirectory = urlResources[NSURLIsDirectoryKey] as? Bool
                    where urlIsDirectory == false {
                        return url
                }
                return .None
            }
            
            let optionalDirectories = enumeratorObjects.map { object -> NSURL? in
                if let url = object as? NSURL,
                    let urlResources = url.resourceValuesForKeys(urlKeys, error: nil),
                    let urlIsDirectory = urlResources[NSURLIsDirectoryKey] as? Bool
                    where urlIsDirectory == true {
                        return url
                }
                return .None
            }
            
            let files = Array.filterOptionals(optionalFiles)
            let directories = Array.filterOptionals(optionalDirectories)
            
            if files.count == 0 && directories.count == 0 {
                // this returns the original URL if no other files and directories were found
                // this happens when the user drags a file rather than a URL
                return URLEnumeration(files: [self], remainingDirectories: directories)
            } else {
                return URLEnumeration(files: files, remainingDirectories: directories)
            }
        }
        return .None
    }
    
    class func URLsFromPasteboard(pasteboard: NSPasteboard) -> [NSURL]? {
        typealias TypeString = String
        
        //
        // A word of warning... The pasteboard API is necessary
        // The only way to get data out of Pasteboard Items it is with Types
        // The only way to get the types is to ask each Pasteboard Item for Its Types
        // Below we will iterate over each item to get the type
        // Then iterate over each item and type to get the URL's
        //
        
        // unwrap the pasteboard items array and convert it into a typed array
        if let optionalPasteboardItems = pasteboard.pasteboardItems?.map({ object -> NSPasteboardItem? in return object as? NSPasteboardItem }) {
            // get ride of the optionals in the pasteboard items array
            let pasteboardItems = Array.filterOptionals(optionalPasteboardItems)
            
            // extract a deduplicated list of all the possible types in the pasteboard items
            let types = Array(Set(Array.flatten(Array.filterOptionals(pasteboardItems.map({ item -> [TypeString]? in
                let optionalTypes = item.types?.map() { object -> TypeString? in return object as? TypeString }
                if let optionalTypes = optionalTypes { return Array.filterOptionals(optionalTypes) } else { return .None }
            })))))
            
            // extract all the possible URLs in the pasteboard items
            let URLs = Array.flatten(types.map({ type -> [NSURL] in
                let mappedURLs = pasteboardItems.map() { item -> NSURL? in
                    if let url = NSURL(pasteboardPropertyList: item.propertyListForType(type), ofType: type) {
                        return url
                    } else {
                        return .None
                    }
                }
                return Array.filterOptionals(mappedURLs)
            }))
            
            // if there are URL's return them
            if URLs.count > 0 { return Array(URLs) } else { return nil }
        }
        // we failed the inital if let check, return nothing
        return .None
    }
    
    public override var description: String {
        return "\(self.path)"
    }
}

struct URLEnumeration {
    var files = [NSURL]()
    var remainingDirectories = [NSURL]()
}

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

//typealias CWCartfile = NSURL

// MARK: Extensions of Built in Types

extension Array {
    static func flatten(array: [[T]]) -> [T] {
        return array.reduce([T](), combine: +)
    }
    
    static func filterOptionals(array: [T?]) -> [T] {
        return array.filter { $0 != nil }.map { $0! }
    }
    
    static func merge(input: [[T]]) -> [T] {
        var output = [T]()
        for inputItem in input {
            output += inputItem
        }
        return output
    }
    
    static func merge(input: [[T]?]) -> [T] {
        var output = [T]()
        for inputItem in input {
            if let inputItem = inputItem {
                output += inputItem
            }
        }
        return output
    }
    
    subscript (safe index: Int) -> Element? {
        return index < count && index >= 0 ? self[index] : nil
    }
    
    subscript (unsafe index: Int) -> Element {
        return self[index]
    }
    
    subscript (yolo index: Int) -> Element { // YOLO! Crashes if out of range
        return self[index]
    }
    
    func lastIndex() -> Int {
        return self.count - 1
    }
}

extension Set {
    func map<U>(transform: (T) -> U) -> Set<U> {
        return Set<U>(Swift.map(self, transform))
    }
}

extension NSButton {
    class func buttonWithDefaultStyle() -> NSButton {
        let button = NSButton()
        button.bezelStyle = .RoundedBezelStyle
        // TODO: Figure out how to fix the garbage caused by NSCell
        //        (button.cell() as! NSButtonCell).bordered = false
        //        (button.cell() as! NSButtonCell).backgroundStyle = NSBackgroundStyle.Dark
        //        (button.cell() as! NSButtonCell).backgroundColor = NSColor.clearColor()
        return button
    }
}

extension NSTextField {
    class func nonEditableTextField() -> NSTextField {
        let textField = NSTextField()
        textField.bordered = false
        (textField.cell() as? NSTextFieldCell)?.backgroundColor = NSColor.clearColor()
        textField.editable = false
        return textField
    }
}

// MARK: Custom Enums

enum NSFileHandlingPanelResponse: Int {
    case CancelButton = 0, SuccessButton
}

extension NSFileHandlingPanelResponse: Printable {
    var description: String {
        switch self {
        case CancelButton:
            return "NSFileHandlingPanelResponse.CancelButton"
        case SuccessButton:
            return "NSFileHandlingPanelResponse.SuccessButton"
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