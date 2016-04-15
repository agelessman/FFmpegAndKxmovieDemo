//
//  FFVideoItem.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFVideoItem: NSObject,Mappable {

    
    var comment: Int64?
    var tags: Array<FFTag>?
    var bookmark: Int64?
    var text: String?
    
    var up: Int64?
    
    var share_url: String?
    var down: Int64?
    var forward: Int64?
    
    var top_comment: FFComment?
    var u: FFUser?
    var passtime: String?
    
    
    var video: FFVideo?
    var type: String?
    var videoItemId: Int64?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        comment <- map["comment"]
        tags <- map["tags"]
        bookmark <- map["bookmark"]
        text <- map["text"]
        u <- map["u"]
        
        up <- map["up"]
        share_url <- map["share_url"]
        down <- map["down"]
        forward <- map["forward"]
        top_comment <- map["top_comment"]
        u <- map["u"]
         passtime <- map["passtime"]
//        passtime <- (map["passtime"],DateTransform())
        video <- map["video"]
        type <- map["type"]
        
        videoItemId <- map["id"]
    }
}
