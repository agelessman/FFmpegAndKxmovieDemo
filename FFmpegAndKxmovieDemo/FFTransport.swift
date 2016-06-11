//
//  FFTransport.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/6/6.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

protocol FFTransportDelegate : NSObjectProtocol {
    
    func play()
    func pause()
    func stop()
    
    func scrubbingDidStart()
    func scrubbedToTime(time: NSTimeInterval)
    func scrubbingDidEnd()
    
    func jumpedToTime(time: NSTimeInterval)
    
}

protocol FFTransport : NSObjectProtocol {
    
    
     func setCurrentTime(time: NSTimeInterval, duration: NSTimeInterval)
//    func setScrubbingTime(time: NSTimeInterval)
    func playbackComplete()
    
}