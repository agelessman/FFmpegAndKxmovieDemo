//
//  FFSliderView.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/6/1.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit




/// 自定义滑块
class FFSliderView: UIControl {
    
    var completeView: UIView!
    var bgView: CALayer!
    var panView: UIButton!
    var startPoint: CGPoint!
    var endPoint: CGPoint!
    
    var tempValue: CGFloat = 0
    var value: CGFloat {
        set {
            
            self.tempValue = newValue
            
            if newValue * (self.endPoint.x - self.startPoint.x) < self.startPoint.x {
                
                self.panView.centerX = self.startPoint.x
            }
            else if newValue * (self.endPoint.x - self.startPoint.x) > self.endPoint.x {
                
                self.panView.centerX = self.endPoint.x
            }
            else {
                
                self.panView.centerX = newValue * (self.endPoint.x - self.startPoint.x) + self.startPoint.x
            }
            
            self.completeView.right = self.panView.centerX
        }
        get {
            return tempValue
        }
    }// current value

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        
        self.setupBgView()
        self .setupCompleteView()
        self.setupPanView()
    }

    
    override func layoutSubviews() {

        super.layoutSubviews()
        
        self.bgView.left = 0
        self.bgView.width = self.width
        self.bgView.height = 2
        self.bgView.bottom = self.height - 10;
        
        self.completeView.left = -self.width
        self.completeView.top = self.bgView.top
        self.completeView.width = self.width
        self.completeView.height = self.bgView.height
        
        self.panView.left = -3
        self.panView.width = 20
        self.panView.height = self.panView.width
        self.panView.centerY = self.bgView.centerY
        
        // set start end point
        self.startPoint = CGPointMake(self.panView.centerX, self.panView.centerY)
        self.endPoint = CGPointMake(self.width + 3 - self.panView.width / 2, self.panView.centerY)
      
    }
    
    func setupBgView() {
        
        self.bgView = CALayer()
        self.bgView.backgroundColor = UIColor.lightGrayColor().CGColor
        
        self.layer.addSublayer(self.bgView)
    }
    
    func setupCompleteView() {
        
        self.completeView = UIView()
        self.completeView.backgroundColor = UIColor.redColor()

        self.addSubview(self.completeView)
    }
    
    func setupPanView() {
        
        self.panView = UIButton()
        self.panView.backgroundColor = UIColor.clearColor()
        self.panView.userInteractionEnabled = false
        self.panView.setImage(FFHelper.imageNamed("voice-play-progress-icon@2x"), forState: UIControlState.Normal)
        self.panView.adjustsImageWhenHighlighted = false
        self.panView.layer.contentMode = UIViewContentMode.ScaleToFill
        self.addSubview(self.panView)

    }
    
  
    
    func touchDown() {
        
        self.sendActionsForControlEvents(UIControlEvents.TouchDown)
    
    }
    
    func touchUpInside() {
        
        self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
   
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Whether in panView
        let touch = touches.first
        let p = touch?.locationInView(self.panView)
        if let _ = p {
           
            self.sendActionsForControlEvents(UIControlEvents.TouchDown)
        }
        
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        
        let p = touch?.locationInView(self.panView)
        
        if let _ = p {
           
            let point = touch?.locationInView(self)
            
            if let _point = point {
                
                
                // control the pan  position
                if 0 <= _point.x && _point.x <= self.endPoint.x {

                    self.value = _point.x / (self.endPoint.x - self.startPoint.x)
                   
                    if self.value > 1.0 {
                        
                        self.value = 1.0
                    }
                    else if self.value <= 0 {
                        
                        self.value = 0
                    }
                    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                    
                }
            }
            
           
        }

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Whether in panView
        let touch = touches.first
        let p = touch?.locationInView(self.panView)
        if let _ = p {
            
            self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
        
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
     
        // Whether in panView
        let touch = touches?.first
        let p = touch?.locationInView(self.panView)
        if let _ = p {
           
            self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
    }
}
