//
//  Cartfile.swift
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

// MARK: Implement the Struct Type Cartfile

struct Cartfile: DependencyDefinable {
    
    var name: String
    var location: NSURL
    
    init?(location: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        if let path = location.path,
            let lastPathComponent = location.lastPathComponent,
            let possibleCartfilePath = location.URLByAppendingPathComponent(Cartfile.fileName()).path {
                var isDirectory: ObjCBool = false
                if fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) == true {
                    switch isDirectory.boolValue {
                    case false where lastPathComponent.lowercaseString == Cartfile.fileName().lowercaseString:
                        self.location = location.parentDirectory
                        self.name = location.parentDirectory.lastPathComponent!
                    case true where fileManager.fileExistsAtPath(possibleCartfilePath) == true:
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
        return EncodableCartfile(location: self.location)
    }
    
    static func fileName() -> String {
        return "Cartfile"
    }
    
    static func writeEmptyToDirectory(directory: NSURL) -> NSError? {
        let blankFileURL = directory.URLByAppendingPathComponent(Cartfile.fileName(), isDirectory: false)
        let blankData = NSData()
        var error: NSError?
        blankData.writeToURL(blankFileURL, options: NSDataWritingOptions.DataWritingWithoutOverwriting, error: &error)
        return error
    }
}

extension Cartfile: Printable {
    var description: String {
        return "\(self.name) <\(self.location.path!)>"
    }
}

extension Cartfile: Hashable {
    var hashValue: Int {
        return self.name.hashValue
    }
}

extension Cartfile: Equatable {}
func ==(lhs: Cartfile, rhs: Cartfile) -> Bool {
    if lhs.hashValue == rhs.hashValue { return true } else { return false }
}

// MARK: Implement the Encodable Class Type

extension Cartfile {
    // special initializer created for when the user deletes a file that was previously on disk
    // will create an invalid cartfile so the UI can reflect that.
    init(dontVerifyLocation location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
    }
}

final class EncodableCartfile: NSObject, EncodableDependencyDefinable, ProtocolHackDependencyDefinable {
    
    var name: String
    var location: NSURL
    
    init(location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
        super.init()
    }
    
    func decodedCopy() -> DependencyDefinable {
        // special initializer created for when the user deletes a file that was previously on disk
        // will create an invalid cartfile so the UI can reflect that.
        return Cartfile(dontVerifyLocation: location)
    }
    
    required init(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObjectForKey("location") as! NSURL
        self.location = location
        self.name = location.lastPathComponent!
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.location, forKey: "location")
    }
    
}