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
var PlayerItemLoadedTimeRangesContext: String?

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

    var loadedObserverCount: Int = 0

    override init() {
        
        super.init()
        
    }
    
    func configure(URL: NSURL) {
        
        self.asset = nil
        self.playerItem = nil
        self.player = nil

//        configurePlayLoadProgress(URL)
//        let url = NSURL(string: "http://127.0.0.1:12345/vedio.mp4")
        self.asset = AVAsset(URL: URL)

        prepareToPlay()
    }
    
//    func configurePlayLoadProgress(url: NSURL!) {
//        
//        
//        // 创建一个用来为HTTPServer读取文件的路径
//        let webPath = NSHomeDirectory().stringByAppendingString("/Library/Private Documents/Temp")
//        let fileManager = NSFileManager.defaultManager()
//        
//        if !fileManager.fileExistsAtPath(webPath) {
//            do {
//              try fileManager.createDirectoryAtPath(webPath, withIntermediateDirectories: true, attributes: nil)
//            }
//            catch {
//                
//            }
//            
//        }
// 
//        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appdelegate.httpServer.setDocumentRoot(webPath)
//        appdelegate.httpServer.setConnectionClass(PlayHTTPConnection.self)
// 
//        do {
//            
//            try appdelegate.httpServer.start()
//            
//        }catch let error {
//            
//            print(error)
//        }
//        
//        let cachePath = NSHomeDirectory().stringByAppendingString("/Library/Private Documents/Cache")
//        if !fileManager.fileExistsAtPath(cachePath) {
//            do {
//                try fileManager.createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: nil)
//            }
//            catch {
//                
//            }
//            
//        }
//        
//        // 百思不得姐的url要处理一下子
//        // http://bvideo.spriteapp.cn/video/2015/0909/55efe56a584fb_wpd.mp4 
//        // 改成 http://svideo.spriteapp.com/video/2015/0909/55efe56a584fb_wpd.mp4
//        
//        var newURL = url
//        let urlHost = newURL.host
//        var urlStr = newURL.absoluteString
//        if let _ = urlHost {
//            
//            let range = urlStr.rangeOfString(urlHost!)
//            urlStr.replaceRange(range!, with: "svideo.spriteapp.com")
//            
//        }
//        
//        newURL = NSURL(string: urlStr)
//        
//        var complete: UInt64 = 0
//        
//        let request = ASIHTTPRequest(URL: newURL)
//        request.downloadDestinationPath = cachePath + "/video.mp4"
//        request.temporaryFileDownloadPath = webPath + "/video.mp4"
//        
//        request.setBytesSentBlock { (size, total) in
//            
//            file_length = total;
//            
//            complete += size
//            
//            let progress = 1.0 * Float(complete) / Float(total)
//            print(progress)
//            if !self.isplaying && complete > 400000 {
//                
//                self.isplaying = !self.isplaying
//                
//                self.prepareToPlay()
//            }
//        }
//        
//        request.allowResumeForFileDownloads = true
//        request.startAsynchronous()
//        
//    }
    
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

                    
                    self.playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.init(rawValue: 0), context: &PlayerItemLoadedTimeRangesContext)
                
                    self.loadedObserverCount += 1;
                }
            })
        }else if context == &PlayerItemLoadedTimeRangesContext {
            
            dispatch_async(dispatch_get_main_queue(), {

                // buffering
                let playerItem = object as? AVPlayerItem
                guard playerItem != nil else {
                    return
                }
                
                let loadedRanges = playerItem?.loadedTimeRanges
                let timeRange = loadedRanges?.first?.CMTimeRangeValue
                if let _timeRange = timeRange {
                    
                    let startSeconds = CMTimeGetSeconds(_timeRange.start)
                    let durationSeconds = CMTimeGetSeconds(_timeRange.duration)
                    
                    let timeInterval = startSeconds + durationSeconds
                    
                    let totalDuration = CMTimeGetSeconds(playerItem!.duration)
                    
                    (self.transport as! FFOverlayView).sliderView.bufferingValue = CGFloat(timeInterval / totalDuration)
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
            
            if self.playerItem != nil {
                
                let duration = CMTimeGetSeconds(self.playerItem.duration)
                
                if let trans = self.transport {
                    
                    trans.setCurrentTime(currentTime, duration: duration)
                }
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
        
        if self.player != nil {
            
            self.player.rate = 0
        }
        if self.transport != nil {
            
            (self.transport as! FFOverlayView).playbackComplete()
        }
        

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
    
  
    
    func clear() {
        
        stop()
        
        deaTimeEndObserver()
        
        // remove boserver
        if self.playerItem != nil {
            
            self.playerItem.cancelPendingSeeks()
            
            self.loadedObserverCount -= 1;
            print(self.loadedObserverCount)
            if self.loadedObserverCount >= 0 {
                self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            }
            
        }
        
        if self.playerView != nil {
            
            self.playerView.removeFromSuperview()
        }
        
        self.playCell = nil
        self.playerItem = nil
        
    }
    
    deinit
    {
     
        deaTimeEndObserver()
        
    }
}
