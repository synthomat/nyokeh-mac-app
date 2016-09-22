//
//  NyokehApi.swift
//  Nyokeh
//
//  Created by Anton Zering on 27.08.16.
//  Copyright © 2016 Anton Zering. All rights reserved.
//

import Foundation
import Alamofire

open class NyokehApi {
  var serverUrl: String!
  var apiKey: String!
  
  fileprivate func composeUrl(_ subPath: String) -> String {
    return serverUrl + subPath + "?auth=" + apiKey
  }
  
  ///
  ///
  ///
  /// - parameters:
  ///   - int: A pointless `Int` parameter.
  ///   - bool: This `Bool` isn't used, but its default value is `false` anyway…
  func testConnection(_ completion: @escaping (_ isValid: Bool) -> Void) {
    Alamofire.request(.GET, composeUrl("/check"))
      .responseJSON { (response) -> Void in
        let value = response.result.value as? [String: AnyObject]
        
        completion(isValid: value!["auth"] as! String == "valid")
    }
    
  }
  
  func uploadFile(
    _ path: URL,
    progress: ((_ bytesWritten: Int64, _ bytesTotal: Int64) -> Void)! = nil,
    completion: ((_ imgUrl: String) -> Void)!
  ) {
    Alamofire.upload(
      .POST,
      composeUrl("/upload"),
      
      multipartFormData: { multipartFormData in
        multipartFormData.appendBodyPart(fileURL: path, name: "file")
      },
      
      encodingCompletion: { result in
        switch result {
          case .success(let upload, _, _):
            
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
          case .failure(let encodingError):
            print(encodingError);
        }
      }
    )
  }
}
