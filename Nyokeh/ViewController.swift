//
//  ViewController.swift
//  Nyokeh
//
//  Created by Anton Zering on 29.07.15.
//  Copyright (c) 2015 Anton Zering. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController {
  @IBOutlet weak var prefWindow: NSWindow!
  
  var defaults: NSUserDefaults!
  
  
  override func viewDidLoad() {
      super.viewDidLoad()
      // Do view setup here.
      defaults = NSUserDefaults.standardUserDefaults();
  }
  

  
  func upload(filePath: String) {
    var serverPath = defaults.stringForKey("server")?.stringByAppendingPathComponent("upload")
    var authKey = defaults.stringForKey("authKey")
    
    Alamofire.upload(
      .POST,
      URLString: "\(serverPath!)?auth=\(authKey!)",
      multipartFormData: { multipartFormData in
        multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: filePath)!, name: "file")
      },
      
      encodingCompletion: { result in
        switch result {
          case .Success(let upload, _, _):
            upload.progress { (_, bytesWritten, totalBytes) -> Void in
              //println(bytesWritten)
            }

            upload.responseJSON { request, response, JSON, error in

              let code = response?.statusCode;

              if (!contains([200, 201], code!)) {
                return;
              }

              let jsonResult = JSON as! Dictionary<String, String>
              NSSound(named: "Bottle.aiff")?.play()
              let url = jsonResult["url"]!
              
              if (self.defaults.boolForKey("shallOpenInBrowser")) {
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
              }
              
              if (self.defaults.boolForKey("shallCopyToClipboard")) {
                var pasteBoard = NSPasteboard.generalPasteboard()

                
                // first you must clear the contents of the clipboard in order to write to it.
                pasteBoard.clearContents()
                
                // now read write our String and an Array with 1 item at index 0
                pasteBoard.writeObjects([url]);
              }
              
              let fileManager = NSFileManager.defaultManager()
              fileManager.removeItemAtPath("/tmp/screencap.png", error: nil)
            }
          case .Failure(let encodingError):
            println(encodingError);
        }
      }
    )
    
  }
  
  @IBAction func takeScreenshot(sender: AnyObject) {
    let task = NSTask()
    task.launchPath = "/usr/sbin/screencapture"
    task.arguments = ["-C", "-W", "/tmp/screencap.png"]
    
    task.launch()
    task.waitUntilExit()
    
    if (task.terminationStatus == 0) {
      upload("/tmp/screencap.png")
    }

  }
  
  @IBAction func testConnection(sender: AnyObject) {
    var serverPath = defaults.stringForKey("server")?.stringByAppendingPathComponent("check")
    var authKey = defaults.stringForKey("authKey")
    
    Alamofire.request(.GET, "\(serverPath!)?auth=\(authKey!)")
      .responseJSON { _, _, JSON, _ in
        let alert:NSAlert = NSAlert();
        alert.messageText = "Info";
        
        if (JSON!["auth"] as! String == "valid") {
          alert.informativeText = "Okay!";
        } else {
          alert.informativeText = "Error! Please check credentials.";
        }
        
        alert.runModal();
    }
  }
  

  @IBAction func showPreferences(sender: AnyObject) {
    prefWindow.makeKeyAndOrderFront(self)
    NSApp.activateIgnoringOtherApps(true)
  }
}
