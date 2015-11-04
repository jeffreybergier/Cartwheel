//
//  DependencyDefinableListModel.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/21/15.
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

protocol DependencyDefinableListModelControllable: class {
    var dataSource: DependencyDefinableListModel { get }
}

class DependencyDefinableListModel {
    
    // MARK: Properties (Private)
    
    private let log = XCGLogger.defaultInstance()
    private let defaults = DefaultsPlist()
    
    // MARK: Properties (Internal)
    
    let modelObserver = ObserverSet<Void>()
    
    private(set) var dependencyDefinables = [DependencyDefinable]() {
        didSet {
            Async.main {
                // notify observers on main thread
                self.modelObserver.notify()
                }.userInitiated {
                    // save to disk in the background
                    if self.cartfileStorageFolderExists() == false {
                        self.log.info("Storage folder does not exist, creating it.")
                        self.createCartfileStorageFolder()
                    }
                    var writeToDiskError: NSError?
                    let encodableDDs = self.dependencyDefinables.map() { dd -> EncodableDependencyDefinable in
                        return dd.encodableCopy()
                    }
                    NSKeyedArchiver.archivedDataWithRootObject(encodableDDs).writeToURL(self.storageFolder.URLByAppendingPathComponent(self.defaults.storageFile), options: nil, error: &writeToDiskError)
                    
                    if let error = writeToDiskError {
                        self.log.error("Error saving files to disk: \(error)")
                    }
            }
        }
    }
    
    // MARK: Mutating Methods (Internal)
    
    func appendDependencyDefinable(newDD: DependencyDefinable) {
        self.dependencyDefinables = insertItems([newDD], intoArray: self.dependencyDefinables, atIndex: self.dependencyDefinables.count)
    }
    
    func appendDependencyDefinables(newDDs: [DependencyDefinable]) {
        self.dependencyDefinables = insertItems(newDDs, intoArray: self.dependencyDefinables, atIndex: self.dependencyDefinables.count)
    }
    
    func insertDependencyDefinables(newDDs: [DependencyDefinable], atIndex index: Int) {
        self.dependencyDefinables = insertItems(newDDs, intoArray: self.dependencyDefinables, atIndex: index)
    }
    
    func moveDependencyDefinablesAtIndexes(indexes: NSIndexSet, toIndex index: Int) {
        self.dependencyDefinables = self.moveItemsAtIndexes(indexes.ranges, toIndex: index, ofArray: self.dependencyDefinables)
    }
    
    func removeDependencyDefinablesAtIndexes(indexes: [Range<Int>]) {
        self.dependencyDefinables = self.removeItemsAtIndexes(indexes, fromArray: self.dependencyDefinables)
    }
    
    // MARK: Pure Functions – Don't Rely on or Modify State (Private)
    
    private func removeItemsAtIndexes<T>(indexes: [Range<Int>], fromArray array: [T]) -> [T] {
        var mutableArray = array
        for range in Array(indexes.reverse()) {
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
    
    private func moveItemsAtIndexes<T>(indexes: [Range<Int>], toIndex index: Int, ofArray inputArray: [T]) -> [T] {
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
        for range in Array(indexes.reverse()) {
            outputCollection.removeRange(range)
        }
        return outputCollection
    }
    
    private func numberOfItemsInIndexes(indexes: [Range<Int>], beforeIndex index: Int) -> Int {
        let indexArray = Array.merge(indexes.map({ range -> [Int] in
            return range.map() { i -> Int in
                return i
            }
        }))
        
        let filteredIndexArray = indexArray.filter() { i -> Bool in
            if i < index { return true } else { return false }
        }
        
        return filteredIndexArray.count
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
    
    private let fileManager = NSFileManager.defaultManager()
    private let storageFolder: NSURL = {
        let array = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        return NSURL(fileURLWithPath: (array.last! as NSString).stringByAppendingPathComponent(DefaultsPlist().storageDirectory))
    }()
    
    private func cartfileStorageFolderExists() -> Bool {
        return self.fileManager.fileExistsAtPath(self.storageFolder.path!)
    }
    
    private func createCartfileStorageFolder() -> Bool {
        do {
            try self.fileManager.createDirectoryAtPath(self.storageFolder.path!, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch _ {
            return false
        }
    }
    
    // MARK: Initialization
    
    init() {
        self.dependencyDefinables = self.readDependencyDefinablesFromDisk()
    }
    
    private func readDependencyDefinablesFromDisk() -> [DependencyDefinable] {
        let fileURL = self.storageFolder.URLByAppendingPathComponent(self.defaults.storageFile)
        
        var fileReachableError: NSError?
        let fileURLIsReachable: Bool
        do {
            try fileURL.checkResourceIsReachableAndReturnError()
            fileURLIsReachable = true
        } catch var error as NSError {
            fileReachableError = error
            fileURLIsReachable = false
        }
        if let error = fileReachableError {
            self.log.error("Error reading Cartfiles from disk: \(error)")
        }
        
        var readFromDiskError: NSError?
        if fileURLIsReachable == true {
            if let dataOnDisk = NSData(contentsOfURL: fileURL, options: []),
                let unarchivedObjects = NSKeyedUnarchiver.unarchiveObjectWithData(dataOnDisk) as? [AnyObject] {
                    let dependencyDefinables = unarchivedObjects.filter() { object -> Bool in
                        if let encodableCartfile = object as? ProtocolHackDependencyDefinable {
                            return true } else { return false }
                        }.map() { object -> DependencyDefinable in
                            return (object as! ProtocolHackDependencyDefinable).decodedCopy()
                    }
                    return dependencyDefinables
            }
        }
        if let error = readFromDiskError {
            self.log.error("Error reading Cartfiles from disk: \(readFromDiskError)")
        }
        return [DependencyDefinable]()
    }
}

