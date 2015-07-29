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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
  
  func upload(filePath: String) {
    Alamofire.upload(
      .POST,
      URLString: "http://localhost:3000/upload?key=f5f92673ec36e5f0055ae3dcbb8da4457a16a6f9",
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
              println(JSON);
              let jsonResult = JSON as! Dictionary<String, String>
              
              NSWorkspace.sharedWorkspace().openURL(NSURL(string: jsonResult["url"]!)!)
              
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
    task.arguments = ["-C", "-i", "/tmp/screencap.png"]
    
    
    task.launch()
    task.waitUntilExit()
    
    if (task.terminationStatus == 0) {
      upload("/tmp/screencap.png")
    }

  }
}
