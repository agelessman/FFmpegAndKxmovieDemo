//
//  FFComment.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFComment: NSObject,Mappable {

    
    var voicetime: Int64?
    var precid: Int64?
    var content: String?
    var count: Int64?
    
    var u: FFUser?
    
    var preuid: Int64?
    var voiceuri: String?
    var commentid: Int64?
    
   
    
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        voicetime <- map["voicetime"]
        precid <- map["precid"]
        content <- map["content"]
        count <- map["count"]
        u <- map["u"]
        
        preuid <- map["preuid"]
        voiceuri <- map["voiceuri"]
        commentid <- map["id"]
        
    }
}
