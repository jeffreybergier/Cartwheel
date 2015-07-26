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
    
    private let log = XCGLogger.defaultInstance()
    private let defaultsPlist = CWDefaultsPlist()
    
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
    
    // MARK: Mutating Methods
    
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
    func insertCartfiles(newCartfiles: [CWCartfile], atIndex index: Int) {
    //func insertCartfiles<S: SequenceType where S.Generator.Element == CWCartfile>(newCartfiles: S, atIndex index: Int) {
        self.cartfiles = self.insertItems(newCartfiles, intoCollection: self.cartfiles, atIndex: index)
    }
    
    func moveCartfilesAtIndexes(indexes: NSIndexSet, toIndex index: Int) {
        self.cartfiles = self.moveArray(self.cartfiles, itemsAtIndexes: indexes.ranges, toIndex: index)
    }
    
    // MARK: Pure Functions (Don't modify/rely on any state)
    private func insertItems<T: Equatable>(items: [T], intoCollection collection: [T], atIndex index: Int) -> [T] {
        var outputCollection = collection
        var mutableIndex = index
        for item in collection {
            if indexOfItem(item, inArray: collection) == .None {
                outputCollection.insert(item, atIndex: mutableIndex)
                mutableIndex++
            } else {
                self.log.info("object found in set \(collection)")
            }
        }
        return outputCollection
    }
    
    private func moveArray<T: Equatable>(inputArray: [T], itemsAtIndexes indexes: [Range<Int>], toIndex index: Int) -> [T] {
        // gather a mutable copy of the array
        var outputArray = inputArray
        
        // iterate through the ranges in reverse to remove them from the mutableArray
        for range in indexes.reverse() {
            outputArray.removeRange(range)
        }
        
        // iterate through the ranges forward to gather the moved items into their own array
        var movedItems = [T]()
        for range in indexes {
            for index in range {
                movedItems += [inputArray[index]]
            }
        }
        
        // get the index of the item that is at the inseration row
        if let itemAtInsertionPoint = inputArray[safe: index],
            var itemAtInsertionRowIndex = self.indexOfItem(itemAtInsertionPoint, inArray: outputArray) {
                // iterate through the gathered items to move and start inserting them at the insertion row
                for movedItem in movedItems {
                    outputArray.insert(movedItem, atIndex: itemAtInsertionRowIndex)
                    itemAtInsertionRowIndex++
                }
        } else {
            // adding thing to the end of the array
            outputArray += movedItems
        }
        
        // save the result
        return outputArray
    }
    
    private func indexOfItem<T: Equatable>(item: T, inArray array: [T]) -> Int? {
        for (index, arrayItem) in enumerate(array) {
            if arrayItem == item { return index }
        }
        return .None
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
