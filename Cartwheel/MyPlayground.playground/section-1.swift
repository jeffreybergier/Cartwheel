// Playground - noun: a place where people can play

import Cocoa
import XCPlayground
import PureLayout_Mac

class CartListViewController: NSViewController {
    
    weak var window: NSWindow!
    
    private var constraints: [NSLayoutConstraint]?
    private let contentView = NSView()
    
    override func loadView() {
        self.view = NSView()
        
        self.contentView.wantsLayer = true
        self.contentView.layer?.backgroundColor = NSColor.blueColor().CGColor
        self.contentView.frame = NSRect(x: 10, y: 10, width: 30, height: 30)
        self.view.addSubview(self.contentView)
        
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
        
        let toolbar = NSToolbar(identifier: "PreferencesToolbar")
        self.window.toolbar = toolbar
    }
    
}

class CartListWindowController: NSWindowController {
    
    let viewController: CartListViewController
    
    override init() {
        let styleMask: Int = NSTitledWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask | NSResizableWindowMask //| NSFullScreenWindowMask
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 400), styleMask: styleMask, backing: NSBackingStoreType.Buffered, defer: true)
        
        self.viewController = CartListViewController()
        
        super.init(window: window)
        self.viewController.window = window
        self.window?.contentView = self.viewController.view
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let wc = CartListWindowController()
wc.showWindow(nil)
let viewToShow: NSView! = wc.window!.contentView as NSView

XCPShowView("Container View", viewToShow)
