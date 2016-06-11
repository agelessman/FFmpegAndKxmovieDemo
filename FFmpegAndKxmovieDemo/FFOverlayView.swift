//
//  FFOverlayView.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/5/31.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

class FFOverlayView: UIView,FFTransport,UIGestureRecognizerDelegate {
    

    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var playView: UIView!
    
    weak var delegate: FFTransportDelegate?
    
    @IBOutlet weak var sliderView: FFSliderView!
    
    var infoViewOffset: CGFloat = 0
    var duration: NSTimeInterval = 0
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    var scrubbing: Bool = false   // is scrubbing or not
    
    var timer: NSTimer?
    var controlsHiden: Bool = false   // is hiden or not
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
        setPlayButtonStatusWithIsPlaying(true)
        
        
        
        self.sliderView.addTarget(self, action: #selector(FFOverlayView.unhidePopupUI), forControlEvents: UIControlEvents.TouchDown)
        self.sliderView.addTarget(self, action: #selector(FFOverlayView.hidePopupUI), forControlEvents: UIControlEvents.TouchUpInside)
        self.sliderView.addTarget(self, action: #selector(FFOverlayView.showPopupUI), forControlEvents: UIControlEvents.ValueChanged)
        
        resetTimer()
    }

    func setPlayButtonStatusWithIsPlaying(isPlaying: Bool) {
        
        self.playButton.selected = isPlaying
   
    }
    

    @IBAction func playback(sender: UIButton) {
        
        sender.selected = !sender.selected
        if let dele = self.delegate {
            
            let sel = sender.selected ? #selector(KxAudioManagerProtocol.play) : #selector(KxAudioManagerProtocol.pause)
            
            dele.performSelector(sel)
        }
    }
    
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        
        setPlayViewStatus(!self.playView.hidden)
    }
    
    
    //MARK: - private method
    
    func setPlayViewStatus(isHiden: Bool) {
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.playView.alpha = isHiden ? 0 : 1;
            
        }) { (finished) in
            
            self.playView.hidden = isHiden
            
        }
        
        self.controlsHiden = isHiden
    }

    func formatSeconds(value: Int) -> String {
        
        let seconds = value % 60
        let minutes = value / 60
        
        return String(format: "%02ld:%02ld", minutes,seconds)
    }
    
    func resetTimer() {
        
        self.timer?.invalidate()
        self.timer = nil
        if !self.scrubbing {
            
            self.timer = NSTimer(timeInterval: 5.0, block: { (timer) in
                
                if self.timer!.valid && !self.controlsHiden {
                    
                    self.setControlStatus()
                }
                
                }, repeats: false)
            
            NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    func setControlStatus() {
        
        UIView.animateWithDuration(0.3) { 
            
            if !self.controlsHiden {
                
                self.setPlayViewStatus(true)
            }
            else {
                
                self.setPlayViewStatus(false)
            }
            
            self.controlsHiden = !self.controlsHiden
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        resetTimer()
        return true
    }
    //MARK: - slider view method
    func unhidePopupUI() {
        
        self.scrubbing = true
        if let dele = self.delegate {
            
            dele.scrubbingDidStart()
        }
        
        resetTimer()
    }
    func hidePopupUI() {
       
        self.scrubbing = false
        if let dele = self.delegate {
            
            dele.scrubbingDidEnd()
        }
    }
    func showPopupUI() {
        
        let seconds = ceil(self.duration * Double(self.sliderView.value))
        
        self.currentTimeLabel.text = formatSeconds(Int(seconds))
     
        if let dele = self.delegate {
            
            dele.scrubbedToTime(seconds)
        }
    }
    
    // FFTransport protocol
    func setCurrentTime(time: NSTimeInterval, duration: NSTimeInterval) {
        
        self.duration = duration;
        let seconds = ceil(time)
        
        if duration .isNaN {
           
            return
        }
        self.currentTimeLabel.text = formatSeconds(Int(seconds))
        self.durationLabel.text = formatSeconds(Int(duration))
        
        self.sliderView.value = CGFloat(time / duration)
    }
    
    func playbackComplete() {
        
        self.sliderView.value = 0.0
        self.playButton.selected = false
    }
    
}
