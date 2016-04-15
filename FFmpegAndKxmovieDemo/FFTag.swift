//
//  FFTag.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFTag: NSObject,Mappable {

    var tagid: Int64?
    var name: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        tagid <- map["id"]
        name <- map["name"]
    }
}
