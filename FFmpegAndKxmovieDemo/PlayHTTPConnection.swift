//
//  PlayHTTPConnection.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/6/30.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

var file_length: UInt64 = 0

class PlayHTTPConnection: HTTPConnection {

    override func httpResponseForMethod(method: String!, URI path: String!) -> protocol<NSObjectProtocol, HTTPResponse>! {
        
        
//        // Override me to provide custom responses.
//        let filePath = self.filePathForURI(path, allowDirectory: false)
//
//        let isDir: UnsafeMutablePointer<ObjCBool> = nil
//        
//        if  NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory:isDir) && !isDir.memory {
//            
//            /**
//             * 这里是要返回文件的总长度，因为视频播放要首先知道文件的总长度，在这里是采用的归档的方式，这样的话每段数据真实的长度就无法给到请求方
//             */
//            let fileResponse = HTTPFileResponse(filePath: filePath, forConnection: self)
//            fileResponse.setValue("\(file_length)", forKey: "file_length")
//            return fileResponse
//        }
//        
       
        
        return super.httpResponseForMethod(method, URI: path)
    }
}
