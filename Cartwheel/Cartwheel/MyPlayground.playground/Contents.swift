//: Playground - noun: a place where people can play

import Foundation

// MARK: Implement the Protocols

protocol DependencyDefinable { //TODO: Figure out how to add in Printable, Hashable without creating errors
    
    static func fileName() -> String //TODO: convert this to property when allowed by swift
    var name: String { get set }
    var location: NSURL { get set }
    func encodableCopy() -> EncodableDependencyDefinable // because these should be implemented as structs, this will require that they be encodable to disk
    
}

protocol EncodableDependencyDefinable: NSCoding {
    
    var name: String { get set }
    var location: NSURL { get set }
    //func decodedCopy<DD: DependencyDefinable>() -> DD
    func decodedCopy() -> DependencyDefinable
}

// MARK: Implement the Struct Type Cartfile

struct Cartfile: DependencyDefinable {
    
    static func fileName() -> String {
        return "Cartfile"
    }
    
    var name: String
    var location: NSURL
    
    init(location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
    }
    
    func encodableCopy() -> EncodableDependencyDefinable {
        return EncodableCartfile(location: self.location)
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

final class EncodableCartfile: NSObject, EncodableDependencyDefinable {
    
    var name: String
    var location: NSURL
    
    init(location: NSURL) {
        self.location = location
        self.name = location.lastPathComponent!
        super.init()
    }
    
    func decodedCopy() -> DependencyDefinable {
        return Cartfile(location: self.location)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObjectForKey("location") as! NSURL
        self.location = location
        self.name = location.lastPathComponent!
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.location, forKey: "location")
    }
    
}

// MARK: Play with it in Playgrounds

var mainArray = [DependencyDefinable]()
let file = Cartfile(location: NSURL(string: "file:///Volumes/Drobo")!)
mainArray += [file] as [DependencyDefinable]
print(mainArray.count)


let encodable = file.encodableCopy()
let fileCopy = encodable.decodedCopy()
print(fileCopy)



if let cartfile = fileCopy as? Cartfile {
    print("yay!")
}
