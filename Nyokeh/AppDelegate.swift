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

  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
    
    statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    statusItem.title = "Nyokeh"
    statusItem.menu = menu;
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }


  @IBAction func quitApplication(sender: AnyObject) {
    NSApplication.sharedApplication().terminate(self)
  }
}

