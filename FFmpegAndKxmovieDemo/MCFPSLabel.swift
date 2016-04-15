//
//  MCFPSLabel.swift
//  weibo-swift
//
//  Created by 马超 on 15/12/28.
//  Copyright © 2015年 马超. All rights reserved.
//

import UIKit


let kFPSSize = CGSizeMake(70, 20)

class MCFPSLabel: UILabel {

    var link :CADisplayLink!
    var count :Int
    var lastTime :NSTimeInterval!
    var upFont :UIFont?
    var subFont :UIFont!
    
  
    override init( frame: CGRect) {
        
         count = 0
        
        super.init(frame: frame)
        
        
        link = CADisplayLink(target: self, selector: #selector(MCFPSLabel.tick(_:)))
        link.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        
        lastTime = 0
        upFont = UIFont(name: "Menlo", size: 12)
        if (upFont != nil)
        {
            subFont = UIFont(name: "Menlo", size: 4)!
        }else
        {
            upFont = UIFont(name: "Courier", size: 12)
            subFont = UIFont(name: "Courier", size: 4)!
        }
        if frame.size.width == 0 && frame.size.height == 0
        {
            self.frame.size = kFPSSize
        }
        
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.textAlignment = NSTextAlignment.Center
        self.userInteractionEnabled = false
        self.backgroundColor = UIColor(white: 0.000, alpha: 0.700)
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tick(link :CADisplayLink)
    {
        if self.lastTime == 0
        {
            self.lastTime = link.timestamp
            return
        }
        
        count += 1
        
        
        
        let delta :NSTimeInterval = link.timestamp - lastTime
        
        if delta < 1
        {
            return
        }
        lastTime = link.timestamp
        let fps :Double = Double(count) / delta
        count = 0
        
        
        let progress :Double = fps / 60.0
        let color = UIColor(hue: CGFloat(0.27 * (progress - 0.2)), saturation: 1, lightness: 0.9, alpha: 1)
        let text = NSMutableAttributedString(string: String.init(format: "%d FPS", Int(round(CGFloat(fps)))))
        text.yy_setColor(color, range: NSMakeRange(0, text.length - 3))
        text.yy_setColor(UIColor.whiteColor(), range: NSMakeRange(text.length - 3, 3))
        text.yy_font = font
        text.yy_setFont(font, range: NSMakeRange(text.length - 4, 1))
        
        self.attributedText = text
    }
    
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        return kFPSSize
    }
    
    deinit
    {
        self.link.invalidate()
    }

}
