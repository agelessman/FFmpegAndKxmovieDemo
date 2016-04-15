//
//  FFBasicRequest.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import Alamofire



class FFBasicRequest: NSObject {

   static  let shareInstance: FFBasicRequest = FFBasicRequest()
    
    func fetchDataWith(url: String? , parameter: [String:AnyObject]? ,completionHandler: ((AnyObject? , String?) -> Void)?) {
        
        if url == nil {
            
            return
        }
        
        Alamofire.request(.POST, url!, parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { response in
            
            if let _ = completionHandler {
                
                completionHandler!(response.result.value,response.result.error?.description)
            }
        }
    }
}
