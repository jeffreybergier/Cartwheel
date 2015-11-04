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
        switch Cartfile.determineInitOption(location) {
        case .File:
            self.location = location.parentDirectory
            self.name = location.parentDirectory.lastPathComponent!
        case .Directory:
            self.location = location
            self.name = location.lastPathComponent!
        case .Fail:
            return nil
        }
    }
    
    func encodableCopy() -> EncodableDependencyDefinable {
        return EncodableCartfile(location: self.location)!
    }
    
    static func fileName() -> String {
        return "Cartfile"
    }
    
    static func writeEmptyToDirectory(directory: NSURL) -> NSError? {
        let blankFileURL = directory.URLByAppendingPathComponent(Cartfile.fileName(), isDirectory: false)
        let blankData = NSData()
        var error: NSError?
        do {
            try blankData.writeToURL(blankFileURL, options: NSDataWritingOptions.DataWritingWithoutOverwriting)
        } catch let error1 as NSError {
            error = error1
        }
        return error
    }
}

extension Cartfile {
    static func determineInitOption(location: NSURL) -> DependencyDefinableInitOption {
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        
        if let path = location.path,
            let lastPathComponent = location.lastPathComponent,
            let possibleCartfilePath = location.URLByAppendingPathComponent(Cartfile.fileName()).path
            where fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) == true {
                switch isDirectory.boolValue {
                case false where lastPathComponent.lowercaseString == Cartfile.fileName().lowercaseString:
                    return .File
                case true where fileManager.fileExistsAtPath(possibleCartfilePath) == true:
                    return .Directory
                default:
                    return .Fail
                }
        }
        return .Fail
    }
}

extension Cartfile: CustomStringConvertible {
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
    
    let name: String
    let location: NSURL
    
    init?(location: NSURL) {
        switch Cartfile.determineInitOption(location) {
        case .File:
            self.location = location.parentDirectory
            self.name = location.parentDirectory.lastPathComponent!
            super.init()
        case .Directory:
            self.location = location
            self.name = location.lastPathComponent!
            super.init()
        case .Fail:
            self.name = "empty"
            self.location = location
            super.init()
            return nil
        }
    }
    
    func decodedCopy() -> DependencyDefinable {
        // special initializer created for when the user deletes a file that was previously on disk
        // will create an invalid cartfile so the UI can reflect that.
        return Cartfile(dontVerifyLocation: location)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.location = aDecoder.decodeObjectForKey("location") as! NSURL
        self.name = aDecoder.decodeObjectForKey("name") as! String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.location, forKey: "location")
        aCoder.encodeObject(self.name, forKey: "name")
    }
    
}