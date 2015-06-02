//: Playground - noun: a place where people can play

import Cocoa

// MARK: Defaults.plist file

struct CWDefaultsPlist {
    var cartfileDirectorySearchRecursion: Int
    var cartListSaveLocation: String
    
    init() {
        var dataError: NSError?
        var plistError: NSError?
        let plistURL = NSBundle.mainBundle().URLForResource("CartwheelDefaults", withExtension: "plist")!
        let data = NSData(contentsOfURL: plistURL, options: nil, error: &dataError)!
        let plist = NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions.allZeros, format: nil, error: &plistError) as! NSDictionary
        
        let cartfileDirectorySearchRecursion = plist["CartfileDirectorySearchRecursion"] as! NSNumber
        let cartListSaveLocation = plist["CartListSaveLocation"] as! String
        
        self.cartfileDirectorySearchRecursion = cartfileDirectorySearchRecursion.integerValue
        self.cartListSaveLocation = cartListSaveLocation
    }
}

extension CWDefaultsPlist: Printable {
    var description: String {
        return "CWDefaultsPlist: cartfileDirectorySearchRecursion: \(self.cartfileDirectorySearchRecursion) – cartListSaveLocation: \(self.cartListSaveLocation)"
    }
}

let defaults = CWDefaultsPlist()
println(defaults)