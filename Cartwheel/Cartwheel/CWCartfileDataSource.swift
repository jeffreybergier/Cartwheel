//
//  CWCartfileDataSource.swift
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

import Foundation
import ObserverSet
import XCGLogger
import Async

final class CWCartfileDataSource {
    
    // MARK: Data Observing
    
    let cartfileObserver = ObserverSet<Void>()
    
    // MARK: Private Properties
    
    let log = XCGLogger.defaultInstance()
    
    // MARK: Internal Properties
    
    let defaultsPlist = CWDefaultsPlist()
    
    private(set) var cartfiles = [CWCartfile]() {
        didSet {
            Async.main {
                // notify observers on main thread
                self.cartfileObserver.notify()
            }.userInitiated {
                // save to disk in the background
                if self.cartfileStorageFolderExists() == false {
                    NSLog("CWCartfileDataSource: Cartfile storage folder does not exist, creating it.")
                    self.createCartfileStorageFolder()
                }
                var writeToDiskError: NSError?
                let archivableCartfiles = self.cartfiles.map() { cartfile -> CWEncodableCartfile in
                    return cartfile.encodableCopy()
                }
                NSKeyedArchiver.archivedDataWithRootObject(archivableCartfiles).writeToURL(self.cartfileStorageFolder.URLByAppendingPathComponent(self.defaultsPlist.cartfileListSaveName), options: nil, error: &writeToDiskError)
                
                if let error = writeToDiskError {
                    NSLog("CWCartfileDataSource: Error saving cartfiles to disk: \(error)")
                }
            }
        }
    }
    
    // MARK: Internal Methods
    
    func addCartfile(newCartfile: CWCartfile) {
        let existingFilesSet = Set(self.cartfiles)
        if existingFilesSet.indexOf(newCartfile) == .None {
            self.cartfiles += [newCartfile]
        } else {
            self.log.info("object found in set \(newCartfile)")
        }
    }
    
    func addCartfiles<S: SequenceType where S.Generator.Element == CWCartfile>(newCartfiles: S) {
        let cartfiles = Set(self.cartfiles)
        for cartfile in newCartfiles {
            if cartfiles.indexOf(cartfile) == .None {
                self.cartfiles += [cartfile]
            } else {
                self.log.info("object found in set \(cartfile)")
            }
        }
    }
    
    func insertCartfiles<S: SequenceType where S.Generator.Element == CWCartfile>(newCartfiles: S, atRow row: Int) {
        var mutableRow = row
        let cartfiles = Set(self.cartfiles)
        for cartfile in newCartfiles {
            if cartfiles.indexOf(cartfile) == .None {
                self.cartfiles.insert(cartfile, atIndex: mutableRow)
                mutableRow++
            } else {
                self.log.info("object found in set \(cartfile)")
            }
        }
    }
    
    func moveItemsAtIndexes(items: NSIndexSet, toRow row: Int) {
        var cartfiles = self.cartfiles
        var cartfilesToMove = [CWCartfile]()
        var rangesToRemoveFromCartfiles = [Range<Int>]()
        items.enumerateRangesUsingBlock() { (range, stop) in
            let swiftRange = range.location ..< (range.location + range.length)
            for i in swiftRange {
                if let cartfile = cartfiles[safe: i] {
                    // collect the items to move
                    cartfilesToMove += [cartfile]
                } else {
                    self.log.error("Tried to move items in array that were out of range: \(i)")
                }
            }
            // collect the ranges to remove
            rangesToRemoveFromCartfiles += [swiftRange]
        }
        // remove the items from the end to the beginning
        rangesToRemoveFromCartfiles.reverse().map() { range -> Void in
            cartfiles.removeRange(range)
        }
        // add them back in at the new spot
        cartfilesToMove.reverse().map() { cartfile -> Void in
            let adjustedRow: Int
            if row <= 0 || cartfiles.count == 0 {
                adjustedRow = 0
            }else if row > (cartfiles.count - 1) {
                adjustedRow = cartfiles.count - 1
            } else {
                adjustedRow = row
            }
            //println("trying to insert Cartfile <\(cartfile)> into rawRow: \(row) adjustedRow: \(adjustedRow) in array with count: \(cartfiles.count)")
            cartfiles.insert(cartfile, atIndex: adjustedRow)
        }
        // doing it this way so the ivar is only set once.
        self.cartfiles = cartfiles
    }
    
    func writeBlankCartfileToDirectoryPath(directory: NSURL) -> (finalURL: NSURL, error: NSError?) {
        let cartfilePath = directory.URLByAppendingPathComponent(self.defaultsPlist.cartfileFileName, isDirectory: false)
        let blankData = NSData()
        var error: NSError?
        blankData.writeToURL(cartfilePath, options: NSDataWritingOptions.DataWritingWithoutOverwriting, error: &error)
        return (finalURL: cartfilePath, error: error)
    }
    
    func cartfilesFromURL(url: NSURL) -> [CWCartfile]? {
        if let recursedFiles = url.extractFilesRecursionDepth(self.defaultsPlist.cartfileDirectorySearchRecursion) {
            let optionalCartfiles = recursedFiles.map { url -> CWCartfile? in
                if url.lastPathComponent?.lowercaseString == self.defaultsPlist.cartfileFileName.lowercaseString {
                    return CWCartfile(url: url) } else { return .None }
            }
            let cartfiles = Array.filterOptionals(optionalCartfiles)
            if cartfiles.count > 0 { return cartfiles } else { return .None }
        }
        return .None
    }
    
    func cartfilesFromURL(URLs: [AnyObject]) -> [CWCartfile]? {
        let optionalURLs = URLs.map { object -> NSURL? in
            if let url = object as? NSURL { return url } else { return .None }
        }
        let filteredURLs = Array.filterOptionals(optionalURLs)
        let optionalCartfiles = filteredURLs.map { url -> [CWCartfile]? in
            return self.cartfilesFromURL(url)
        }
        let mergedCartfiles = Array.merge(optionalCartfiles)
        if mergedCartfiles.count > 0 { return mergedCartfiles } else { return .None }
    }

    // MARK: Handle Saving Cartfiles to disk
    
    private let fileManager = NSFileManager.defaultManager()
    private let cartfileStorageFolder: NSURL = {
        let array = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        return NSURL(fileURLWithPath: (array.last as! String).stringByAppendingPathComponent(CWDefaultsPlist().cartfileListSaveLocation))!
    }()
    
    private func cartfileStorageFolderExists() -> Bool {
        return self.fileManager.fileExistsAtPath(self.cartfileStorageFolder.path!)
    }
    
    private func createCartfileStorageFolder() -> Bool {
        return self.fileManager.createDirectoryAtPath(self.cartfileStorageFolder.path!, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    // MARK: Handle Launching and Singleton
    
    init() {
        self.cartfiles = self.readCartfilesFromDisk()
    }
    
    private func readCartfilesFromDisk() -> [CWCartfile] {
        let fileURL = self.cartfileStorageFolder.URLByAppendingPathComponent(self.defaultsPlist.cartfileListSaveName)
        
        var fileReachableError: NSError?
        let fileURLIsReachable = fileURL.checkResourceIsReachableAndReturnError(&fileReachableError)
        if let error = fileReachableError {
            NSLog("CWCartfileDataSource: Error reading Cartfiles from disk: \(error)")
        }
        
        if fileURLIsReachable == true {
            var readFromDiskError: NSError?
            if let dataOnDisk = NSData(contentsOfURL: fileURL, options: nil, error: &readFromDiskError),
                let unarchivedObjects = NSKeyedUnarchiver.unarchiveObjectWithData(dataOnDisk) as? [AnyObject] {
                    let cartfiles = Array.filterOptionals(unarchivedObjects.map({ object -> CWCartfile? in
                        if let encodableCartfile = object as? CWEncodableCartfile {
                            return encodableCartfile.decodedCartfile()
                        }
                        return .None
                    }))
                    return cartfiles
            }
            if let error = readFromDiskError {
                NSLog("CWCartfileDataSource: Error reading Cartfiles from disk: \(readFromDiskError)")
            }
        }
        
        return [CWCartfile]()
    }
}
