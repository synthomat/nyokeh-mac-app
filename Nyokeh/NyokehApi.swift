//
//  NyokehApi.swift
//  Nyokeh
//
//  Created by Anton Zering on 27.08.16.
//  Copyright © 2016 Anton Zering. All rights reserved.
//

import Foundation
import Alamofire

public class NyokehApi {
  var serverUrl: String!
  var apiKey: String!
  
  private func composeUrl(subPath: String) -> String {
    return serverUrl + subPath + "?auth=" + apiKey
  }
  
  ///
  ///
  ///
  /// - parameters:
  ///   - int: A pointless `Int` parameter.
  ///   - bool: This `Bool` isn't used, but its default value is `false` anyway…
  func testConnection(completion: (isValid: Bool) -> Void) {
    Alamofire.request(.GET, composeUrl("/check"))
      .responseJSON { (response) -> Void in
        let value = response.result.value as? [String: AnyObject]
        
        completion(isValid: value!["auth"] as! String == "valid")
    }
    
  }
  
  func uploadFile(
    path: NSURL,
    progress: ((bytesWritten: Int64, bytesTotal: Int64) -> Void)! = nil,
    completion: ((imgUrl: String) -> Void)!
  ) {
    Alamofire.upload(
      .POST,
      composeUrl("/upload"),
      
      multipartFormData: { multipartFormData in
        multipartFormData.appendBodyPart(fileURL: path, name: "file")
      },
      
      encodingCompletion: { result in
        switch result {
          case .Success(let upload, _, _):
            
            upload.progress { (_, bytesWritten, totalBytes) -> Void in
              progress?(bytesWritten: bytesWritten, bytesTotal: totalBytes)
            }
            
            upload.responseJSON { (response) -> Void in
              let code = response.response?.statusCode;
              
              if (![200, 201].contains(code!)) {
                return;
              }
              
              let value = response.result.value as? [String: AnyObject]
              let fileUrl = value!["url"] as! String
              
              completion(imgUrl: fileUrl);
            }
          case .Failure(let encodingError):
            print(encodingError);
        }
      }
    )
  }
}