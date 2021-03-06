//
//  DependencyDefinable.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 8/20/15.
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

// MARK: Implement the Protocols

protocol DependencyDefinable: CustomStringConvertible { //TODO: Figure out how to add in Printable, Hashable without creating errors
    static func fileName() -> String //TODO: convert this to property when allowed by swift
    static func writeEmptyToDirectory(directory: NSURL) -> NSError?
    var name: String { get set }
    var location: NSURL { get set }
    func encodableCopy() -> EncodableDependencyDefinable // because these should be implemented as structs, this will require that they be encodable to disk
    init?(location: NSURL)
}

@objc protocol EncodableDependencyDefinable: class, NSCoding {
    var name: String { get }
    var location: NSURL { get }
    init?(location: NSURL)
    //func decodedCopy() -> DependencyDefinable
}

protocol ProtocolHackDependencyDefinable {
    func decodedCopy() -> DependencyDefinable
}

enum DependencyDefinableInitOption {
    case File, Directory, Fail
}

struct DependencyDefinableType {
    
    static func fromURL(url: NSURL) -> [DependencyDefinable]? {
        var dependencyDefinables = [DependencyDefinable]()
        
        let foundCartfiles = url.extractFilesRecursionDepth(DependencyDefinableType.defaults.directorySearchRecursion)?.map() { url -> DependencyDefinable? in
            return Cartfile(location: url)
            }.filter() { dd -> Bool in
                if let dd = dd { return true } else { return false }
            }.map() { verifiedDD -> DependencyDefinable in
                return verifiedDD!
        }
        
        if let found = foundCartfiles {
            dependencyDefinables += found
        }
        
        let foundPodfiles = url.extractFilesRecursionDepth(DependencyDefinableType.defaults.directorySearchRecursion)?.map() { url -> DependencyDefinable? in
            return Podfile(location: url)
            }.filter() { dd -> Bool in
                if let dd = dd { return true } else { return false }
            }.map() { verifiedDD -> DependencyDefinable in
                return verifiedDD!
        }
        
        if let found = foundPodfiles {
            dependencyDefinables += found
        }
        
        
        if dependencyDefinables.isEmpty == false { return dependencyDefinables } else { return .None }
    }
    
    //TODO: Make this work. This code is causing a segmentation fault in swift
//    static func fromURL(url: NSURL) -> [DependencyDefinable]? {
//        var dependencyDefinables = [DependencyDefinable]()
//        
//        // this must be done with the OBJC protocol. It does not yet work with Swift protocols
//        let implementedTypes: [EncodableDependencyDefinable.Type] = [
//            EncodableCartfile.self,
//            EncodablePodfile.self
//        ]
//        
//        for implementedType in implementedTypes {
//            if let urls = url.extractFilesRecursionDepth(DependencyDefinableType.defaults.directorySearchRecursion) {
//                let found = urls.map() { url -> EncodableDependencyDefinable? in
//                    return implementedType(location: url)
//                    }.filter() { dd -> Bool in
//                        if let dd = dd as? ProtocolHackDependencyDefinable { return true } else { return false }
//                    }.map() { encodableDD -> DependencyDefinable in
//                        return (encodableDD as! ProtocolHackDependencyDefinable).decodedCopy()
//                }
//                dependencyDefinables += found
//            }
//        }
//        
//        if dependencyDefinables.isEmpty == false { return dependencyDefinables } else { return .None }
//    }
    
    static func fromURLs(URLs: [AnyObject]) -> [DependencyDefinable]? {
        var dependencyDefinables = [DependencyDefinable]()
        
        for url in URLs {
            if let url = url as? NSURL {
                if let found = DependencyDefinableType.fromURL(url) {
                    dependencyDefinables += found
                }
            }
        }

        if dependencyDefinables.isEmpty == false { return dependencyDefinables } else { return .None }
    }
    
    // defaultsPlist requires disk activity so I only want that to happen once in the lifecycle of the app
    // however, every cartfile that is initalized needs to check to make sure it has a valid URL
    // this defaults plist is where it gets the name it needs
    // creating this private static constant allows me to always check for a valid URL
    // while not having to read from disk every time a cartfile is initialized
    private static let defaults = DefaultsPlist()
}