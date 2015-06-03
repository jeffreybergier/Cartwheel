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

import Foundation

// MARK: Extensions of Built in Types

extension Array {
    static func filterOptionals(array: [T?]) -> [T] {
        return array.filter { $0 != nil }.map { $0! }
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return index < count && index >= 0 ? self[index] : nil
    }
    
    subscript (unsafe index: Int) -> Element {
        return self[index]
    }
    
    subscript (yolo index: Int) -> Element { // YOLO! Crashes if out of range
        return self[index]
    }
}

extension Set {
    func map<U>(transform: (T) -> U) -> Set<U> {
        return Set<U>(Swift.map(self, transform))
    }
}

// MARK: Custom Enums

enum NSFileHandlingPanelResponse: Int {
    case CancelButton = 0, OKButton
}

extension NSFileHandlingPanelResponse: Printable {
    var description: String {
        switch self {
        case CancelButton:
            return "NSFileHandlingPanelResponse.CancelButton"
        case OKButton:
            return "NSFileHandlingPanelResponse.OKButton"
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