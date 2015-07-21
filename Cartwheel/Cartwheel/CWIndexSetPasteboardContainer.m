//
//  CWIndexSetPasteboardContainer.m
//  Cartwheel
//
//  Created by Jeffrey Bergier on 7/18/15.
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

#import "CWIndexSetPasteboardContainer.h"

@implementation CWIndexSetPasteboardContainer

- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    // this is the magic bit.
    // Swift can't return anything in an initializer
    NSData *data = propertyList;
    CWIndexSetPasteboardContainer *container = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    return container;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    return data;
}

- (instancetype)initWithIndexSet: (NSIndexSet *) indexSet {
    if (self = [super init]) {
        _containedIndexSet = indexSet;
        return self;
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSIndexSet *indexSet = [aDecoder decodeObjectForKey:@"containedIndexSet"];
    return [self initWithIndexSet: indexSet];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.containedIndexSet forKey:@"containedIndexSet"];
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    NSString *typeString = (NSString *)kUTTypeData;
    return @[typeString];
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    NSString *typeString = (NSString *)kUTTypeData;
    return @[typeString];
}

// Swift class that I couldn't make work :(

//import Cocoa
//
//class CWIndexSetPasteboardContainerSwift: NSObject, NSPasteboardWriting, NSPasteboardReading, NSCoding {
//    
//    let containedIndexSet: NSIndexSet
//    
//    init(indexSet: NSIndexSet) {
//        self.containedIndexSet = indexSet
//        super.init()
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        println("beginning encode")
//        aCoder.encodeObject(self.containedIndexSet, forKey: "containedIndexSet")
//        println("ended encode")
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        let indexSet = aDecoder.decodeObjectForKey("containedIndexSet") as! NSIndexSet
//        self.containedIndexSet = indexSet
//        super.init()
//    }
//    
//    func writableTypesForPasteboard(pasteboard: NSPasteboard?) -> [AnyObject] {
//        return [kUTTypeData]
//    }
//    
//    func pasteboardPropertyListForType(type: String?) -> AnyObject {
//        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
//        return data
//    }
//    
//    static func readableTypesForPasteboard(pasteboard: NSPasteboard?) -> [AnyObject] {
//        return [kUTTypeData]
//    }
//    
//    required init?(pasteboardPropertyList propertyList: AnyObject?, ofType type: String?) {
//        let coder = NSCoder()
//        coder.setValue(propertyList, forKey: "containedIndexSet")
//        self.containedIndexSet = NSIndexSet()
//        super.init()
//    }
//}

@end
