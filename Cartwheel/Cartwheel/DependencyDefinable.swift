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

protocol DependencyDefinable: Printable { //TODO: Figure out how to add in Printable, Hashable without creating errors
    static func fileName() -> String //TODO: convert this to property when allowed by swift
    static func writeEmptyToDirectory(directory: NSURL) -> NSError?
    var name: String { get set }
    var location: NSURL { get set }
    func encodableCopy() -> EncodableDependencyDefinable // because these should be implemented as structs, this will require that they be encodable to disk
    
}

@objc protocol EncodableDependencyDefinable: class, NSCoding {
    var name: String { get set }
    var location: NSURL { get set }
    //func decodedCopy() -> DependencyDefinable
}

protocol ProtocolHackDependencyDefinable {
    func decodedCopy() -> DependencyDefinable
}