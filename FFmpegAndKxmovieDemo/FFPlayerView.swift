//
//  FFPlayerView.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/5/31.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit
import AVFoundation

class FFPlayerView: UIView {
    
    var overlayView: FFOverlayView!
    
    var transport: FFTransport {
        get {
            return self.overlayView
        }
    }

    init(player: AVPlayer) {
        
        super.init(frame: CGRectZero)
        
        self.backgroundColor = UIColor.blackColor()
        self.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        
        (self.layer as! AVPlayerLayer).player = player
        
       self.overlayView = NSBundle.mainBundle().loadNibNamed("FFOverlayView", owner: self, options: nil).first as! FFOverlayView
    
        self.addSubview(self.overlayView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override class func layerClass() -> AnyClass {
        
        return AVPlayerLayer.self
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.overlayView.frame = self.bounds
    }
}
