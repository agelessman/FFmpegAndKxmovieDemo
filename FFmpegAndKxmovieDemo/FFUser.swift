//
//  FFUser.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFUser: NSObject,Mappable {

    
    /// 认证方式
    internal enum FFUserVerifyType {
        
        case None  //没有认证
        case Standard   //个人认证，黄V
        case Vip   //个人认证，黄V
    }
    
    var is_v: Bool = false
    var uid: Int64?
    var is_vip: Bool = false
    var name: String?
    var verifyType: FFUserVerifyType = FFUserVerifyType.None

    
    var header: Array<String>?

    
    required init?(_ map: Map) {
        
        if let value = map["is_v"].currentValue {
            
            if value as! Int == 1 {
                
                self.verifyType = FFUserVerifyType.Standard
                
            }
    
        }
        

        if let value = map["is_vip"].currentValue {
            
            if value as! Int == 1 {
                
                self.verifyType = FFUserVerifyType.Vip
                
            }
            
        }
        
        
    }

    
    func mapping(map: Map) {
        
        is_v <- map["is_v"]
        uid <- map["uid"]
        is_vip <- map["is_vip"]
        name <- map["name"]
        header <- map["header"]
        
     

    }
}
