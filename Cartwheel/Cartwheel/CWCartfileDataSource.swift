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

protocol CartfileDataSourceControllable: class {
    var dataSource: CWCartfileDataSource { get }
}

class CWCartfileDataSource {
    
    // MARK: Properties (Private)
    
    private let log = XCGLogger.defaultInstance()
    private let defaultsPlist = CWDefaultsPlist()
    
    // MARK: Properties (Internal)
    
    let cartfileObserver = ObserverSet<Void>()
    
    private(set) var cartfiles = [CWCartfile]() {
        didSet {
            Async.main {
                // notify observers on main thread
                self.cartfileObserver.notify()
            }.userInitiated {
                // save to disk in the background
                if self.cartfileStorageFolderExists() == false {
                    self.log.info("Cartfile storage folder does not exist, creating it.")
                    self.createCartfileStorageFolder()
                }
                var writeToDiskError: NSError?
                let archivableCartfiles = self.cartfiles.map() { cartfile -> CWEncodableCartfile in
                    return cartfile.encodableCopy()
                }
                NSKeyedArchiver.archivedDataWithRootObject(archivableCartfiles).writeToURL(self.cartfileStorageFolder.URLByAppendingPathComponent(self.defaultsPlist.cartfileListSaveName), options: nil, error: &writeToDiskError)
                
                if let error = writeToDiskError {
                    self.log.error("Error saving cartfiles to disk: \(error)")
                }
            }
        }
    }
    
    // MARK: Mutating Methods (Internal)
    
    func appendCartfile(newCartfile: CWCartfile) {
        self.cartfiles = insertItems([newCartfile], intoArray: self.cartfiles, atIndex: self.cartfiles.count)
    }
    
    func appendCartfiles(newCartfiles: [CWCartfile]) {
        self.cartfiles = insertItems(newCartfiles, intoArray: self.cartfiles, atIndex: self.cartfiles.count)
    }
    
    func insertCartfiles(newCartfiles: [CWCartfile], atIndex index: Int) {
        self.cartfiles = insertItems(newCartfiles, intoArray: self.cartfiles, atIndex: index)
    }
    
    func moveCartfilesAtIndexes(indexes: NSIndexSet, toIndex index: Int) {
        self.cartfiles = self.moveItemsAtIndexes(indexes.ranges, toIndex: index, ofArray: self.cartfiles)
    }
    
    func writeBlankCartfileToDirectoryPath(directory: NSURL) -> (finalURL: NSURL, error: NSError?) {
        return self.writeEmptyFileToDirectory(directory, withName: self.defaultsPlist.cartfileFileName)
    }
    
    func removeCartfilesAtIndexes(indexes: [Range<Int>]) {
        self.cartfiles = self.removeItemsAtIndexes(indexes, fromArray: self.cartfiles)
    }
    
    // MARK: Pure Functions – Don't Rely on or Modify State (Private)
    
    private func removeItemsAtIndexes<T>(indexes: [Range<Int>], fromArray array: [T]) -> [T] {
        var mutableArray = array
        for range in indexes.reverse() {
            mutableArray.removeRange(range)
        }
        return mutableArray
    }
    
    private func insertItems<T>(items: [T], intoArray inputArray: [T], atIndex index: Int) -> [T] {
        var outputArray = inputArray
        var mutableIndex = index
        if index < inputArray.count {
            for item in items {
                outputArray.insert(item, atIndex: mutableIndex)
                mutableIndex++
            }
        } else {
            outputArray += items
        }
        
        return outputArray
    }
    
    private func moveItemsAtIndexes<T: Equatable>(indexes: [Range<Int>], toIndex index: Int, ofArray inputArray: [T]) -> [T] {
        // gather the items that need to be moved
        let movedItems = self.arrayByExtractingItemsAtIndexes(indexes, fromArray: inputArray)
        // count the number of items that were before the target index so the index can be adjusted
        let indexAdjustment = numberOfItemsInIndexes(indexes, beforeIndex: index)
        // get a collection that has had all the moved items removed from it
        let arraySansMovedItems = arrayByRemovingItemsAtIndexes(indexes, fromArray: inputArray)
        // insert the moved items into the correct index of collectionSansMovedItems
        let outputArray = insertItems(movedItems, intoArray: arraySansMovedItems, atIndex: index - indexAdjustment)

        return outputArray
    }
    
    private func arrayByRemovingItemsAtIndexes<U>(indexes: [Range<Int>], fromArray collection: [U]) -> [U] {
        // TODO: remove this in swift 2.0
        var outputCollection = collection
        for range in indexes.reverse() {
            outputCollection.removeRange(range)
        }
        return outputCollection
    }
    
    private func numberOfItemsInIndexes(indexes: [Range<Int>], beforeIndex index: Int) -> Int {
        var number = 0
        for range in indexes {
            for i in range {
                if i < index {
                    number++
                }
            }
        }
        return number
    }
    
    private func arrayByExtractingItemsAtIndexes<T>(indexes: [Range<Int>], fromArray array: [T]) -> [T] {
        // TODO: remove this in swift 2.0
        var extractedItems = [T]()
        for range in indexes {
            for index in range {
                extractedItems += [array[index]]
            }
        }
        return extractedItems
    }

    // MARK: Writing to Disk (Private)
    
    private func writeEmptyFileToDirectory(directory: NSURL, withName name: String) -> (finalURL: NSURL, error: NSError?) {
        let blankFileURL = directory.URLByAppendingPathComponent(name, isDirectory: false)
        let blankData = NSData()
        var error: NSError?
        blankData.writeToURL(blankFileURL, options: NSDataWritingOptions.DataWritingWithoutOverwriting, error: &error)
        return (finalURL: blankFileURL, error: error)
    }
    
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
    
    // MARK: Initialization
    
    init() {
        self.cartfiles = self.readCartfilesFromDisk()
    }
    
    private func readCartfilesFromDisk() -> [CWCartfile] {
        let fileURL = self.cartfileStorageFolder.URLByAppendingPathComponent(self.defaultsPlist.cartfileListSaveName)
        
        var fileReachableError: NSError?
        let fileURLIsReachable = fileURL.checkResourceIsReachableAndReturnError(&fileReachableError)
        if let error = fileReachableError {
            self.log.error("Error reading Cartfiles from disk: \(error)")
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
                self.log.error("Error reading Cartfiles from disk: \(readFromDiskError)")
            }
        }
        
        return [CWCartfile]()
    }
}
