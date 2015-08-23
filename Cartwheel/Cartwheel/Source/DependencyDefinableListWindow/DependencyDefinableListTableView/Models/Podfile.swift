//
//  Podfile.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/22/15.
//
//  Copyright (c) 2015 Saturday Apps. All rights reserved.
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

// MARK: Implement the Struct Type Podfile

struct Podfile: DependencyDefinable {
    
    var name: String
    var location: NSURL
    
    init?(location: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        if let path = location.path,
            let lastPathComponent = location.lastPathComponent,
            let possiblePodfilePath = location.URLByAppendingPathComponent(Podfile.fileName()).path {
                var isDirectory: ObjCBool = false
                if fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) == true {
                    switch isDirectory.boolValue {
                    case false where lastPathComponent.lowercaseString == Podfile.fileName().lowercaseString:
                        self.location = location.parentDirectory
                        self.name = location.parentDirectory.lastPathComponent!
                    case true where fileManager.fileExistsAtPath(possiblePodfilePath) == true:
                        self.location = location
                        self.name = location.lastPathComponent!
                    default:
                        return nil
                    }
                } else {
                    return nil
                }
        } else {
            return nil
        }
    }
    
    func encodableCopy() -> EncodableDependencyDefinable {
        return EncodablePodfile(location: self.location)
    }
    
    static func fileName() -> String {
        return ".Podfile"
    }
    
    static func writeEmptyToDirectory(directory: NSURL) -> NSError? {
        let blankFileURL = directory.URLByAppendingPathComponent(Podfile.fileName(), isDirectory: false)
        let blankData = NSData()
        var error: NSError?
        blankData.writeToURL(blankFileURL, options: NSDataWritingOptions.DataWritingWithoutOverwriting, error: &error)
        return error
    }
}

extension Podfile: Printable {
    var description: String {
        return "\(self.name) <\(self.location.path!)>"
    }
}

extension Podfile: Hashable {
    var hashValue: Int {
        return self.name.hashValue
    }
}

extension Podfile: Equatable {}
func ==(lhs: Podfile, rhs: Podfile) -> Bool {
    if lhs.hashValue == rhs.hashValue { return true } else { return false }
}

// MARK: Implement the Encodable Class Type

extension Podfile {
    // special initializer created for when the user deletes a file that was previously on disk
    // will create an invalid Podfile so the UI can reflect that.
    init(dontVerifyLocation location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
    }
}

final class EncodablePodfile: NSObject, EncodableDependencyDefinable, ProtocolHackDependencyDefinable {
    
    var name: String
    var location: NSURL
    
    init(location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
        super.init()
    }
    
    func decodedCopy() -> DependencyDefinable {
        // special initializer created for when the user deletes a file that was previously on disk
        // will create an invalid Podfile so the UI can reflect that.
        return Podfile(dontVerifyLocation: location)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.location = aDecoder.decodeObjectForKey("location") as! NSURL
        self.name = aDecoder.decodeObjectForKey("name") as! String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.location, forKey: "location")
        aCoder.encodeObject(self.name, forKey: "name")
    }
    
}