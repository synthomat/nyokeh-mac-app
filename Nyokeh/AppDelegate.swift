//
//  AppDelegate.swift
//  Nyokeh
//
//  Created by Anton Zering on 29.07.15.
//  Copyright (c) 2015 Anton Zering. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  @IBOutlet weak var menu: NSMenu!
  
  var statusItem: NSStatusItem!
  let popover = NSPopover()
  
  
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    statusItem = NSStatusBar.system().statusItem(withLength: -1)
    statusItem.image = NSImage(named: "NyokehMenuIcon")
    statusItem.button?.action = #selector(AppDelegate.togglePopover(_:))
  
    popover.contentViewController = UploadHistoryController(nibName: "UploadHistoryController", bundle: nil)
    

    statusItem.menu = menu;    
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func showPopover(_ sender: AnyObject?) {
    if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
  }
  
  func closePopover(_ sender: AnyObject?) {
    popover.performClose(sender)
  }

  @IBAction func quitApplication(_ sender: AnyObject) {
    NSApplication.shared().terminate(self)
  }
  
  func togglePopover(_ sender: AnyObject?) {
    if popover.isShown {
      closePopover(sender)
    } else {
      showPopover(sender)
    }
  }
}

