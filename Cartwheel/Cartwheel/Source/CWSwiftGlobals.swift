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
import XCGLogger

// MARK: Class for Subcontrollers

class DependencyDefinableListChildController: NSObject {
    weak var controller: protocol<DependencyDefinablesControllable, DependencyDefinableListModelControllable, CartfileWindowControllable>?
    weak var windowObserver: DependencyDefinableListWindowObserver?
}

// MARK: Extend NSRange

extension NSIndexSet {
    var ranges: [Range<Int>] {
        var ranges = [Range<Int>]()
        self.enumerateRangesUsingBlock() { (range, stop) in
            let swiftRange = range.location ..< range.location + range.length
            ranges += [swiftRange]
        }
        return ranges
    }
}

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
        let urlKeys = [NSURLIsDirectoryKey]
        let enumeratorOptions: NSDirectoryEnumerationOptions = [.SkipsHiddenFiles, .SkipsPackageDescendants, .SkipsSubdirectoryDescendants]
        
        let enumerator = fileManager.enumeratorAtURL(self, includingPropertiesForKeys: urlKeys, options: enumeratorOptions) {
            (url: NSURL, error: NSError) -> Bool in
            XCGLogger.defaultInstance().error("NSEnumerator Error: \(error) with URL: \(url)")
            return true
        }
        
        if let enumeratorObjects = enumerator?.allObjects {
            let files = enumeratorObjects.filter() { object -> Bool in
                if let url = object as? NSURL,
                    let urlResources = try? url.resourceValuesForKeys(urlKeys),
                    let urlIsDirectory = urlResources[NSURLIsDirectoryKey] as? Bool
                    where urlIsDirectory == false {
                        return true
                } else {
                    return false
                }
            }.map() { object -> NSURL in
                return object as! NSURL
            }
        
            let directories = enumeratorObjects.filter() { object -> Bool in
                if let url = object as? NSURL,
                    let urlResources = try? url.resourceValuesForKeys(urlKeys),
                    let urlIsDirectory = urlResources[NSURLIsDirectoryKey] as? Bool
                    where urlIsDirectory == true {
                        return true
                } else {
                    return false
                }
            }.map() { object -> NSURL in
                return object as! NSURL
            }
            
            
            if files.isEmpty && directories.isEmpty {
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
        let URLs = pasteboard.readObjectsForClasses([NSURL.self], options: nil)?.filter() { object -> Bool in
            if let url = object as? NSURL { return true } else { return false }
        }.map() { object -> NSURL in
            return object as! NSURL
        }
        
        // fixes a bug where we were sometimes returning an empty array
        if let URLs = URLs where URLs.isEmpty == false { return URLs } else { return .None }
    }
    
    var parentDirectory: NSURL {
        var components = self.pathComponents!
        components.removeLast()
        return NSURL.fileURLWithPathComponents(components)!
    }
}

struct URLEnumeration {
    var files = [NSURL]()
    var remainingDirectories = [NSURL]()
}

// MARK: Fixing Broken AppKit Stuff

extension NSProgressIndicator {
    enum IndicatorState {
        case Indeterminate, Determinate
    }
}

struct CWLayoutPriority {
    static var Required: NSLayoutPriority = 1000
    static var DefaultHigh: NSLayoutPriority = 750
    static var DragThatCanResizeWindow: NSLayoutPriority = 510
    static var WindowSizeStayPut: NSLayoutPriority = 500
    static var DragThatCannotResizeWindow: NSLayoutPriority = 490
    static var DefaultLow: NSLayoutPriority = 250
    static var FittingSizeCompression: NSLayoutPriority = 50
}

//extension NSView {
//    func writeScreenShotToDiskWithName(name: String) -> NSError? {
//        // Capture original invisibility state
//        let originalHiddenState = self.hidden
//        let originalAlphaState = self.alphaValue
//        
//        // change view to be fully visible for screenshot
//        self.hidden = false
//        self.alphaValue = 1.0
//        
//        // create URL in App Support directory
//        let appSupport = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).last! + "/Cartwheel"
//        let appSupportURL = NSURL(fileURLWithPath: appSupport, isDirectory: true)
//        let screenshotFileURL = appSupportURL.URLByAppendingPathComponent(name + ".tiff")
//        
//        // capture screenshot
//        let screenshot = NSImage(data: self.dataWithPDFInsideRect(self.bounds))
//        
//        // save to disk
//        var error: NSError?
//        do {
//            try screenshot?.TIFFRepresentation?.writeToURL(screenshotFileURL, options: NSDataWritingOptions.AtomicWrite)
//        } catch var error1 as NSError {
//            error = error1
//        }
//        
//        // Restore invisiblity state
//        self.hidden = originalHiddenState
//        self.alphaValue = originalAlphaState
//        
//        // return error (if any)
//        return error
//    }
//}

// MARK: Extensions of Built in Types

func indexOfItem<T: Equatable>(item: T, inCollection collection: [T]) -> Int? {
    // TODO: remove this in swift 2.0
    for (index, collectionItem) in collection.enumerate() {
        if item == collectionItem { return index }
    }
    return .None
}

extension Array {
    
    static func arrayByExcludingItemsInArray<E: Hashable>(lhs: [E], andArray rhs: [E]) -> [E]? {
        let lhsSet = Set(lhs)
        let rhsSet = Set(rhs)
        var outputArray = [E]()
        
        func checkItem(item: E, lhs: Set<E>, rhs: Set<E>) -> [E] {
            if !(lhs.contains(item) && rhs.contains(item)) { return [item] } else { return [] }
        }
        
        for leftItem in lhs {
            outputArray += checkItem(leftItem, lhs: lhsSet, rhs: rhsSet)
        }
        for rightItem in rhs {
            outputArray += checkItem(rightItem, lhs: lhsSet, rhs: rhsSet)
        }
        
        if outputArray.count > 0 { return outputArray } else { return .None }
    }
    
    static func flatten<T>(array: [[T]]) -> [T] {
        return array.reduce([T](), combine: +)
    }
    
    static func merge(input: [[Element]]) -> [Element] {
        var output = [Element]()
        for inputItem in input {
            output += inputItem
        }
        return output
    }
    
    static func merge(input: [[Element]?]) -> [Element] {
        var output = [Element]()
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
    func map<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.map(transform))
    }
}

extension NSButton {
    enum Style {
        case Default, Cancel, Warning, Retry
    }
    
    convenience init(style: Style) {
        self.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        switch style {
        case .Default:
            self.bezelStyle = .RoundedBezelStyle
        case .Cancel:
            self.bezelStyle = .TexturedRoundedBezelStyle
            self.title = ""
            self.bordered = false
            self.image = NSImage(named: NSImageNameStopProgressFreestandingTemplate)
        case .Retry:
            self.bezelStyle = .TexturedRoundedBezelStyle
            self.title = ""
            self.bordered = false
            self.image = NSImage(named: NSImageNameRefreshFreestandingTemplate)
        case .Warning:
            self.title = ""
            self.bordered = false
            self.bezelStyle = .TexturedRoundedBezelStyle
            self.image = NSImage(named: NSImageNameCaution)
            (self.cell as? NSButtonCell)?.imageScaling = NSImageScaling.ScaleProportionallyDown
        }
    }
}

extension NSOpenPanel {
    
    enum Style {
        case AddCartfiles
        case CreatBlankCartfile(delegate: NSOpenSavePanelDelegate)
    }
    
    enum Response: Int {
        case CancelButton = 0, SuccessButton
    }
    
    convenience init(style: Style) {
        self.init()
        switch style {
        case .AddCartfiles:
            self.canChooseFiles = true
            self.canChooseDirectories = true
            self.allowsMultipleSelection = true
            self.title = NSLocalizedString("Add Cartfiles", comment: "Title of add cartfiles open panel")
        case .CreatBlankCartfile(let delegate):
            self.delegate = delegate
            self.canChooseDirectories = true
            self.canCreateDirectories = true
            self.canChooseFiles = false
            self.allowsMultipleSelection = false
            self.title = NSLocalizedString("Create New Cartfile", comment: "Title of the create new cartfile save dialog.")
            self.prompt = CartListOpenPanelDelegate.savePanelOriginalButtonTitle
        }
    }
}

extension NSAlert {
    enum Style {
        case CartfileRemoveConfirm
        
        enum CartfileRemoveConfirmResponse: Int {
            case RemoveButton = 1000
            case CancelButton = 1001
        }
        
        enum CartfileBuildErrorDismissResponse: Int {
            case DismissButton = 1001
            case DismissAndClearButton = 1000
        }
    }
    
    convenience init(style: Style) {
        self.init()
        switch style {
        case .CartfileRemoveConfirm:
            self.addButtonWithTitle("Remove")
            self.addButtonWithTitle("Cancel")
            self.messageText = NSLocalizedString("Remove Selected Cartfiles?", comment: "Description for alert that is shown when the user tries to delete Cartfiles from the main list")
            self.alertStyle = NSAlertStyle.WarningAlertStyle
        }
    }
}

extension NSTextField {
    enum Style {
        case TableRowCellTitle
    }
    
    convenience init(style: Style) {
        self.init()
        switch style {
        case .TableRowCellTitle:
            self.bordered = false
            (self.cell as? NSTextFieldCell)?.backgroundColor = NSColor.clearColor()
            self.editable = false
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