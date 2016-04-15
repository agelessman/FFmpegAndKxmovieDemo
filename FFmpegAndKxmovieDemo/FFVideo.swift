//
//  FFVideo.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFVideo: NSObject,Mappable {

    var playfcount: Int64?
    var height: Int64?
    var width: Int64?
    var duration: Int64?
    var playcount: Int64?
    
    var video: Array<String>?
    var thumbnail: Array<String>?
    var download: Array<String>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        playfcount <- map["playfcount"]
        height <- map["height"]
        width <- map["width"]
        duration <- map["duration"]
        playcount <- map["playcount"]
        
        
        video <- map["video"]
        thumbnail <- map["thumbnail"]
        download <- map["download"]
    }
}
