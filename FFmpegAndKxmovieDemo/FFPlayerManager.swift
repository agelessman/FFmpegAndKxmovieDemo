//
//  FFPlayerManager.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/6/6.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit
import AVFoundation

var PlayerItemStatusContext: String?

let REFRESH_INTERVAL: CGFloat = 1 / 60

class FFPlayerManager: NSObject,FFTransportDelegate {
    
    var view: UIView {
        get {
            return self.playerView
        }
    }
    
    var playCell: FFHomeCell?
    
    var asset: AVAsset!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var playerView: FFPlayerView!
    
    var transport: FFTransport?
    
    var timeObserver: AnyObject?
    var itemEndObserver: AnyObject?
    
    var lastPlaybackRate: Float = 0

    override init() {
        
        super.init()
        
    }
    
    func configure(URL: NSURL) {
        
        self.asset = nil
        self.playerItem = nil
        self.player = nil
        self.asset = AVAsset(URL: URL)
        prepareToPlay()
    }
    
    func prepareToPlay() {
        
        let keys = ["tracks","duration","commonMetadata","availableMediaCharacteristicsWithMediaSelectionOptions"]
        self.playerItem = AVPlayerItem(asset: self.asset, automaticallyLoadedAssetKeys: keys)
        
        self.playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.init(rawValue: 0), context: &PlayerItemStatusContext)
        self.player = AVPlayer(playerItem: self.playerItem)
        
        self.playerView = FFPlayerView(player: self.player)
        
        self.transport = self.playerView.transport
        
        (self.transport as! FFOverlayView).delegate = self
        
        (self.transport as! FFOverlayView).setPlayViewStatus(true)
        
    }
    
    // observe
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &PlayerItemStatusContext {
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                self.playerItem.removeObserver(self, forKeyPath: "status")
                
   
                if self.playerItem.status == AVPlayerItemStatus.ReadyToPlay {
                    
                    // send message to cell
                    NSNotificationCenter.defaultCenter().postNotificationName("playBegan", object: nil)
 
                    // set up time abservers
                    self.addPlayerItemTimeObserver()
                    self.addItemEndObserverForPlayerItem()
                    // set up ui
                    
                    // play
                    self.player.play()
                    
                
                }
            })
        }
    }
    
    //MARK: - private method
    func addPlayerItemTimeObserver() {
        
        // Create 0.5 second refresh interval - REFRESH_INTERVAL == 0.5
        let interval = CMTimeMakeWithSeconds(Float64(REFRESH_INTERVAL), Int32(NSEC_PER_SEC))
        
        // Main dispatch queue
        let queue = dispatch_get_main_queue()

        // Add observer and store pointer for future use
        self.timeObserver = nil
        self.timeObserver = self.player.addPeriodicTimeObserverForInterval(interval, queue: queue, usingBlock: { (time) in
            
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(self.playerItem.duration)
            
            if let trans = self.transport {
                
                trans.setCurrentTime(currentTime, duration: duration)
            }
        })
    }
    
    
    func addItemEndObserverForPlayerItem() {
        
        let name = AVPlayerItemDidPlayToEndTimeNotification
        
        // Add observer and store pointer for end
        self.itemEndObserver = NSNotificationCenter.defaultCenter().addObserverForName(name, object: self.playerItem, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) in
            
            self.player.seekToTime(kCMTimeZero, completionHandler: { (finished) in
        
                (self.transport as! FFOverlayView).playbackComplete()
            })
        })
    }
  
    
    //MARK:- FFTransport delegate
    func play() {
       
        self.player.play()
    }
    
    func pause() {
       
        self.lastPlaybackRate = self.player.rate
        self.player.pause()
    }
    
    func stop() {
        
        self.player.rate = 0
        (self.transport as! FFOverlayView).playbackComplete()
    }
    
    func scrubbingDidStart() {
        
        self.lastPlaybackRate = self.player.rate
        self.player.pause()
        if let _ = self.timeObserver {
            
            self.player.removeTimeObserver(self.timeObserver!)
        }
        
    }
    
    func scrubbingDidEnd() {
        
        self.addPlayerItemTimeObserver()
        
        // play is begining
        if self.lastPlaybackRate > 0 {
            
            self.player.play()
        }
    }
    
    func scrubbedToTime(time: NSTimeInterval) {
        
        self.playerItem .cancelPendingSeeks()
        self.player.seekToTime(CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func jumpedToTime(time: NSTimeInterval) {
        
    }
    
    func deaTimeEndObserver() {
        
        if let _ = self.itemEndObserver {
            
            NSNotificationCenter.defaultCenter().removeObserver(self.itemEndObserver!, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.currentItem)
            self.itemEndObserver = nil
        }
    }
    
    deinit
    {
     
        deaTimeEndObserver()
    }
}
