//
//  CartListTableCellViewController.swift
//  Cartwheel
//
//  Created by Jeffrey Bergier on 4/28/15.
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

import Cocoa
import PureLayout_Mac
import CarthageKit
import ReactiveCocoa
import Commandant

final class CartListTableCellViewController: NSTableCellView {
        
    let contentView = CartListTableCellView()
    
    var cartfile: CWCartfile! {
        didSet {
            self.prepareCellForNewModelObject()
            self.updateCellWithNewModelObject()
        }
    }
    
    static let identifier = "CartListTableCellViewController"
    override var identifier: String? {
        get { return self.classForCoder.identifier }
        set { /* do nothing */ /* this setter is needed to please the compiler */ }
    }
    
    private func prepareCellForNewModelObject() {
        self.contentView.clearCellContents()
    }
    
    private func updateCellWithNewModelObject() {
        if let cartfileTitle = self.cartfile?.name {
            self.contentView.setPrimaryTextFieldString(cartfileTitle)
        } else {
            self.contentView.clearCellContents()
        }
    }
    
    private var configured = false
    
    func configureViewIfNeeded() {
        if self.configured == false {
            // configure the view
            self.addSubview(self.contentView)
            self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
            self.contentView.viewDidLoad()
            
            // configure the button
            self.contentView.setPrimaryButtonTitle(NSLocalizedString("Update", comment: "Button to perform carthage update"))
            self.contentView.setPrimaryButtonAction("didClickUpdateCartfileButton:", forTarget: self)
            self.configured = true
        }
    }
    
    @objc private func didClickUpdateCartfileButton(sender: NSButton) {
        println("didClickUpdateCartfileButton -- Begin")
        
        let buildPlatforms = SignalProducer(values: [
            self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .Mac),
            self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .iOS),
            self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .watchOS)
            ])
            |> flatten(.Concat)
        
        self.cartfile.project.updateDependencies()
            |> on(started: {
                println("Updating Dependencies")
            })
            |> on(completed: {
                println("Finished Updating Dependencies")
                buildPlatforms
                    |> on(started: {
                        println("Starting All Builds..")
                    })
                    |> on(completed: {
                        println("Finished All Builds")
                    })
                    |> start(next: { build in
                        build
                            |> on(started: {
                                println("Build Started...")
                            })
                            |> on(completed: {
                                println("Build Ended...")
                            })
                            |> start()
                    })
            })
            |> start()

        
//        self.cartfile.project.updateDependencies()
//            |> then(self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .Mac))
//            |> doNext({ build in return build })
//            |> then(self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .iOS))
//            |> doNext({ build in return build })
//            |> then(self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .WatchOS))
//            |> doNext({ build in return build })
//            |> promoteErrors
//            |> on(complete: {
//                /* handle success */
//            })
//            |> on(fail: { errors in /*handle errors */ })
//            |> start()
        

        
//        var macBuildsInProgress = 0
//        var iosBuildsInProgress = 0
//        var watchBuildsInProgress = 0
//        
//        self.cartfile.project.updateDependencies()
//            |> on(started: {
//                println("Updating Dependencies")
//            })
//            |> on(completed: {
//                println("Finished Updating Dependencies")
//                self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .Mac)
//                    |> start(next: { build in
//                        build
//                            |> on(started: {
//                                macBuildsInProgress++
//                                println("Mac Build has Started. In Progress = \(macBuildsInProgress)")
//                            })
//                            |> on(completed: {
//                                macBuildsInProgress--
//                                println("Mac Build has Completed. In Progress = \(macBuildsInProgress)")
//                            })
//                            |> start()
//                        
//                    })
//                self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .iOS)
//                    |> start(next: { build in
//                        build
//                            |> on(started: {
//                                iosBuildsInProgress++
//                                println("iOS Build has Started. In Progress = \(iosBuildsInProgress)")
//                            })
//                            |> on(completed: {
//                                iosBuildsInProgress--
//                                println("iOS Build has Completed. In Progress = \(iosBuildsInProgress)")
//                            })
//                            |> start()
//                        
//                    })
//                self.cartfile.project.buildCheckedOutDependenciesWithConfiguration("", forPlatform: .watchOS)
//                    |> start(next: { build in
//                        build
//                            |> on(started: {
//                                watchBuildsInProgress++
//                                println("WatchOS Build has Started. In Progress = \(watchBuildsInProgress)")
//                            })
//                            |> on(completed: {
//                                watchBuildsInProgress--
//                                println("WatchOS Build has Completed. In Progress = \(watchBuildsInProgress)")
//                            })
//                            |> start()
//                        
//                    })
//            })
//            |> start()
        
        println("didClickUpdateCartfileButton -- End")
    }
    
    // MARK: Special Property used to Calculate Row Height
    
    var viewHeightForTableRowHeightCalculation: CGFloat {
        return self.contentView.viewHeightForTableRowHeightCalculation
    }
}
