//
//  FFVideoPlayView.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/19.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

let LOCAL_MIN_BUFFERED_DURATION: CGFloat = 0.2
let LOCAL_MAX_BUFFERED_DURATION: CGFloat = 0.4
let NETWORK_MIN_BUFFERED_DURATION: CGFloat = 2.0
let NETWORK_MAX_BUFFERED_DURATION: CGFloat = 4.0


var leftFrames: Int = 0
var correction: NSTimeInterval = 0
var time: NSTimeInterval = 0
var now: NSTimeInterval = 0
var delta: CGFloat = 0


var bytes: UnsafePointer<Void> = nil
var bytesLeft: UInt = 0
var frameSizeOf: UInt = 0
var bytesToCopy: UInt = 0
var framesToCopy: UInt = 0



class FFVideoPlayView: UIView {
    
    var playing: Bool = false
    var decoding: Bool = false
    
    
    var paramers: Dictionary<String,AnyObject>?
    var _interrupted: Bool = false
    var _decoder: KxMovieDecoder!
    var _dispatchQueue: dispatch_queue_t!
    var _videoFrames: Array<KxMovieFrame> = Array()
    var _audioFrames: Array<KxMovieFrame> = Array()
    var _subtitles: Array<KxMovieFrame> = Array()
    
    var _glView: KxMovieGLView?
    var _imageView: UIImageView?
    
    var _minBufferedDuration: CGFloat = 0
    var _maxBufferedDuration: CGFloat = 0
    var _bufferedDuration: CGFloat = 0
    
    var _disableUpdateHUD: Bool = false
    var _tickCorrectionTime: NSTimeInterval = 0
    var _tickCorrectionPosition: NSTimeInterval = 0
    var _tickCounter: UInt = 0
    
    #if DEBUG
    var _messageLabel: UILabel?
    var _debugStartTime: NSTimeInterval = 0
    var _debugAudioStatus: UInt = 0
    var _debugAudioStatusTS: NSDate?
    #endif
    
    var artworkFrame: KxArtworkFrame?
    var _buffered: Bool = false
    var _moviePosition: CGFloat = 0
    var _activityIndicatorView: UIActivityIndicatorView!
    
    var _currentAudioFrame:NSData?
    var _currentAudioFramePos: UInt = 0
    
    var lock: NSLock = NSLock()


    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - public
    // 加载视频数据，同时返回是否加载成功
    func loadVideoWithPath(path: String? , parameters: Dictionary<String,AnyObject>?,completionHandler: ((Bool) -> Void)) {
        
        if path == nil {
           completionHandler( false )
            return
        }
        
        self._moviePosition = 0
        self.paramers = parameters
        self.configureAudio()
        self.configureDecoderWithPath(path!) { (done) in
            
            completionHandler( done )
        }

    }
    
    func play() {
        
        if self.playing {
            
            return
        }
        
        if !self._decoder.validVideo && !self._decoder.validAudio {
            
            return
        }
        
        if self._interrupted {
            
            return
        }
        
        self.playing = true
        self._interrupted = false
        self._disableUpdateHUD = false
        self._tickCorrectionTime = 0
        self._tickCounter = 0
        
        #if DEBUG
            self._debugStartTime = -1
        #endif
        
        self.asyncDecodeFrames()
        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.1) )
        dispatch_after(popTime, dispatch_get_main_queue()) { 
            
            self.tick()
        }
        
        if self._decoder.validAudio {
            
            self.enableAudio(true)
        }
        
    }
    
    
    //MARK: - private
    
    
    
    // - 是否开启音频功能
    func enableAudio(on: Bool) {
        
        let audioManager = KxAudioManager.audioManager()
        
        if on && self._decoder.validAudio {
            
            audioManager.outputBlock = { (  outData: UnsafeMutablePointer<Float> ,var numFrames: UInt32 , numChannels: UInt32 ) -> Void in
           
                self.audioCallbackFillData( outData, numFrames: &numFrames, numChannels: numChannels)
            }
            
            audioManager.play()
        }
        else {
            
            audioManager.pause()
            audioManager.outputBlock = nil
        }
    }
    
    func audioCallbackFillData(var  outData: UnsafeMutablePointer<Void> ,inout numFrames: UInt32 , numChannels: UInt32) {
        
        if _buffered {
            
            memset(outData , 0, Int(numFrames * numChannels) * sizeof(Float))
            return
        }
        
        autoreleasepool { 
        
             while numFrames > 0 {

                
                if _currentAudioFrame == nil {
                    
//                    synced(self, closure: { 
//                  self.lock.lock()

                        let count = self._audioFrames.count
                        if count > 0 {
                            
    
                            let frame = self._audioFrames[0] as? KxAudioFrame
                            
                            if let audioFrame = frame {
                                
                                #if DUMP_AUDIO_DATA
                                    print("Audio frame position: \(frame.position)")
                                #endif
                                
                                if self._decoder.validVideo {
                                    
                                    delta = self._moviePosition - audioFrame.position
                                    if delta < -0.1 {
                                        
                                        memset(outData , 0, Int(numFrames * numChannels) * sizeof(Float))
                                        #if DEBUG
                                            print("desync audio (outrun) wait \(self._moviePosition) \(audioFrame.position)")
                                            self._debugAudioStatus = 1
                                            self._debugAudioStatusTS = NSDate()
                                        #endif
                                        
                                        break
                                    }
                                    
                                    self._audioFrames.removeAtIndex(0)
                                    
                                    if delta > 0.1 && count > 1 {
                                        
                                        #if DEBUG
                                            print("desync audio (lags) wait \(self._moviePosition) \(audioFrame.duration)")
                                            self._debugAudioStatus = 2
                                            self._debugAudioStatusTS = NSDate()
                                        #endif
                                        
                                        continue
                                    }
                                }
                                else {
                                    
                                    self._audioFrames.removeAtIndex(0)
                                    self._moviePosition = audioFrame.position
                                    self._bufferedDuration -= audioFrame.duration
                                    
                                }
                                
                                self._currentAudioFramePos = 0
                                self._currentAudioFrame = audioFrame.samples
                            }
                            
                        }
                        
//                    })
//                    self.lock.unlock()

                }

                if let currentAudioFrame = self._currentAudioFrame {
                   
                    bytes = currentAudioFrame.bytes + Int(self._currentAudioFramePos)
                    bytesLeft = UInt(currentAudioFrame.length) - self._currentAudioFramePos
                    frameSizeOf = UInt(numChannels) * UInt(sizeof(Float))
                    bytesToCopy = min(UInt(numFrames) * frameSizeOf, bytesLeft)
                    framesToCopy = bytesToCopy / frameSizeOf
                    
                    memcpy(outData, bytes, Int(bytesToCopy))

                    numFrames -= UInt32(framesToCopy)

                    outData += Int(UInt32(framesToCopy) * numChannels)
                    
                    if (bytesToCopy < bytesLeft) {
                        _currentAudioFramePos += bytesToCopy
                    }
                    else {
                        _currentAudioFrame = nil
                    }
                }
                else {
                    
                    memset(outData , 0, Int(numFrames * numChannels) * sizeof(Float))
                    #if DEBUG
                        print("desync audio (outrun) wait \(self._moviePosition) \(audioFrame.position)")
                        self._debugAudioStatus = 3
                        self._debugAudioStatusTS = NSDate()
                    #endif
                }
            }
            
        }
    }
    
    func tick () {
        
        if self._buffered && ( (self._bufferedDuration > self._minBufferedDuration) || self._decoder.isEOF) {
            
            self._tickCorrectionTime = 0
            self._buffered = false
            self._activityIndicatorView.stopAnimating()
        }
        
        var interval: CGFloat = 0
        if !self._buffered {
           
            interval = self.presentFrame()
        }
        
        if self.playing {
            
            leftFrames =
                (self._decoder.validVideo ? self._videoFrames.count : 0) +
                (_decoder.validAudio ? _audioFrames.count : 0)
            
            if leftFrames == 0 {
                
                if self._decoder.isEOF {
                    
                    self.pause()
                    self.updateHUD()
                    return
                }
                
                if _minBufferedDuration > 0 && !_buffered {
                    
                    _buffered = true
                    self._activityIndicatorView.startAnimating()
                }
            }
            
            
            if (leftFrames == 0 ||
                !(_bufferedDuration > _minBufferedDuration)) {
                
                self.asyncDecodeFrames()
            }
            
            correction = self.tickCorrection()
            time = max(Double(interval) + correction, 0.01)

            let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * time) )
            dispatch_after(popTime, dispatch_get_main_queue()) {
                
                self.tick()
            }
     
        }
        
        if ((( self._tickCounter + 1 ) % 3) == 0) {
           
            self.updateHUD()
        }
    }
    
    func pause() {
        
    }
    
    func updateHUD() {
        
    }
    
    func tickCorrection() -> Double {
        
        if self._buffered {
            
            return 0
        }

        now = NSDate.timeIntervalSinceReferenceDate()
        
        if self._tickCorrectionTime == 0 {
            
            self._tickCorrectionTime = now
            self._tickCorrectionPosition = Double(self._moviePosition)
            return 0
        }
        

        let dPosition = Double(_moviePosition) - _tickCorrectionPosition
        let dTime = now - _tickCorrectionTime
        var correction = dPosition - dTime
        
        if (correction > 1 || correction < -1) {
            
            correction = 0
            _tickCorrectionTime = 0
        }
        
        return correction
    }
    
    
    func presentFrame() -> CGFloat {
        
        var interval: CGFloat = 0
  
        if self._decoder.validVideo {
            
            var frame: KxVideoFrame?
            
            synced(self, closure: {
            
                if self._videoFrames.count > 0 {
                    
                    frame = self._videoFrames[0] as? KxVideoFrame
                    if frame != nil {
                        
                        self._videoFrames.removeAtIndex(0)
                        self._bufferedDuration -= frame!.duration
                    }
                    
                }
            })

            
            if let frame = frame {
                
                interval = self.presentVideoFrame(frame)
            }
        }
        else if self._decoder.validAudio {
            
            if let artworkFrame = self.artworkFrame {
                
                self._imageView!.image = artworkFrame.asImage()
                self.artworkFrame = nil
            }
        }
        
        if self._decoder.validSubtitles {
            
            self.presentSubtitles()
        }
        
        #if DEBUG
            if self.playing && self._debugStartTime < 0 {
               
                self._debugStartTime = NSDate.timeIntervalSinceReferenceDate() - self._moviePosition
            }
        #endif
        
        return interval
    }
    
    func presentSubtitles() {
        
    }
    
    func presentVideoFrame(frame: KxVideoFrame) -> CGFloat {
        
        if let glView = self._glView {
            
            glView.render(frame)
        }
        else {
            
            let rgbFrame = frame as? KxVideoFrameRGB
            self._imageView?.image = rgbFrame?.asImage()
        }
        
        self._moviePosition = frame.position;
        
        return frame.duration;
    }
    
    func asyncDecodeFrames() {
        
        if self.decoding {
            
            return
        }
        
        let duration: CGFloat = self._decoder.isNetwork ? 0 : 0.1
        
        self.decoding = true
        dispatch_async(self._dispatchQueue) { 
            
            if !self.playing {
                
                return
            }
            
            var good = true
            while (good) {
                
                good = false
                
                autoreleasepool({ 
                    
                    if self._decoder != nil && (self._decoder.validVideo || self._decoder.validAudio) {
                        
                        let frames = self._decoder.decodeFrames(duration)
                        
                        if frames.count > 0 {
                            
                            good = self.addFrames(frames as! [KxMovieFrame])
                        }
                        
                        
                    }
                })
             
            }
        }
        
        self.decoding = false
        
    }
    
    func addFrames(frames: [KxMovieFrame]) -> Bool {
        
        if self._decoder.validVideo {  // video
            
            synced(self, closure: { 
                for frame in frames {
                    
                    if frame.type == KxMovieFrameTypeVideo {
                        
                        self._videoFrames.append(frame)
                        self._bufferedDuration += frame.duration
                    }
                }
            })

        }
        
        if self._decoder.validAudio {  // dudio
            
            synced(self, closure: { 
                for frame in frames {
                    
                    if frame.type == KxMovieFrameTypeAudio {
                        
                        self._audioFrames.append(frame)
                        if !self._decoder.validVideo {
                            self._bufferedDuration += frame.duration
                        }
                        
                    }
                }
            })
  
            // 插图
            if !self._decoder.validVideo {
                
                for frame in frames {
                    
                    if frame.type == KxMovieFrameTypeArtwork {
                        
                       self.artworkFrame = frame as? KxArtworkFrame
                    }
                }
            }
            
        }
        
        if self._decoder.validSubtitles  {
            
            synced(self, closure: { 
                for frame in frames {
                    
                    if frame.type == KxMovieFrameTypeSubtitle {
                        
                        self._subtitles.append(frame)
                    }
                }
            })
        }
     
        return self.playing && self._bufferedDuration < self._maxBufferedDuration
    }
    
    // - configure decoder
    func configureDecoderWithPath(path: String , completionHandler: ((Bool) -> Void)) {
        
        let decoder = KxMovieDecoder()
        decoder.interruptCallback = { _ in
            
            return self.window != nil ? self.interruptDecoder() : true
        }
        
        // read path
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            
            do {
  
                try decoder.openFile(path)

                dispatch_async_on_main_queue({ 
                    
                    // 通知 文件读取完成
                    completionHandler( true )
                    
                    self.setupMovieWithDecoder(decoder)
                })
            }
            catch let error {
                
                completionHandler( false )
                print(error)
            }
            
        }
    }
    
    // - setupMovie
    func setupMovieWithDecoder(decoder: KxMovieDecoder) {
        
        //
        self._decoder = decoder
        self._dispatchQueue = dispatch_queue_create("myMovie", DISPATCH_QUEUE_SERIAL)
        
        if decoder.subtitleStreamsCount > 0 {
            
            self._subtitles = Array()
        }
        
        if decoder.isNetwork {
            
            self._minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION
            self._maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION
        }
        else {
            
            self._minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION
            self._maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION
        }
        
        if !decoder.validVideo {
            
            self._minBufferedDuration *= 10.0
            
            let alert = UIAlertView(title: "decoder/validVideo/erro", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        // allow to tweak some parameters at runtime
        if let parameters = self.paramers {
            
            if parameters.count > 0 {
                
                var val: NSNumber?
                
                val = parameters[KxMovieParameterMinBufferedDuration] as? NSNumber
                
                if let _ = val {
                    
                    self._minBufferedDuration = CGFloat(val!.floatValue)
                }
                
                val = parameters[KxMovieParameterMaxBufferedDuration] as? NSNumber
                
                if let _ = val {
                    
                    self._maxBufferedDuration = CGFloat(val!.floatValue)
                }
                
                val = parameters[KxMovieParameterDisableDeinterlacing] as? NSNumber
                
                if let _ = val {
                    
                    self._decoder.disableDeinterlacing = val!.boolValue
                }

                if self._maxBufferedDuration < self._minBufferedDuration {
                    
                    self._maxBufferedDuration = self._minBufferedDuration * 2
                }
                

            }
        }
        
        print(" ---- min: \(self._minBufferedDuration) , ---- max: \(self._maxBufferedDuration)")
        
        self.setupPresentView()
        
        self.restorePlay()
    
    }
    
    func restorePlay() {
        
        self.play()
//        NSNumber *n = [gHistory valueForKey:_decoder.path];
//        if (n)
//        [self updatePosition:n.floatValue playMode:YES];
//        else
//        [self play];
    }
    
    // - setupPresentView
    func setupPresentView() {
    
        let bounds = self.bounds
        
        if self._decoder.validVideo {
            
            self._glView = KxMovieGLView(frame: bounds, decoder: self._decoder)
            
            if self._glView == nil {
                
                print("fallback to use RGB video frame and UIKit")
                
                self._decoder.setupVideoFrameFormat(KxVideoFrameFormatRGB)
                
                self._imageView = UIImageView(frame: bounds)
                self._imageView?.backgroundColor = UIColor.blackColor()
            }
            
            let frameView = self.frameView()
            frameView.contentMode = UIViewContentMode.ScaleAspectFit
            frameView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth,
                                          UIViewAutoresizing.FlexibleHeight,
                                          UIViewAutoresizing.FlexibleTopMargin,
                                          UIViewAutoresizing.FlexibleLeftMargin,
                                          UIViewAutoresizing.FlexibleBottomMargin,UIViewAutoresizing.FlexibleRightMargin]
            
            self.insertSubview(frameView, atIndex: 0)
            
            if self._decoder.validVideo {
                
                self.setupUserInteraction()
            }
            else {
                
                self._imageView?.image = UIImage(named: "kxmovie.bundle/music_icon.png")
                self._imageView?.contentMode = UIViewContentMode.Center
            }
        }
        
    }
    
    // - setter GestureRecognizer
    func setupUserInteraction() {
        
        
    }
    
    // - get frame view
    func frameView() -> UIView {
        
        return self._glView != nil ? self._glView! : self._imageView!
    }
        
        
        
    // - configure audio
    func configureAudio() {
        
        let audioManager = KxAudioManager.audioManager()
        audioManager.activateAudioSession()
        
    }
    
    // - private methods
    func interruptDecoder() -> Bool {
        
        return self._interrupted
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.setupViews()
    }
    
    func setupViews() {
        
        self._activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self._activityIndicatorView.center = self.center
        self._activityIndicatorView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth,
                                                        UIViewAutoresizing.FlexibleHeight,
                                                        UIViewAutoresizing.FlexibleTopMargin,
                                                        UIViewAutoresizing.FlexibleLeftMargin,
                                                        UIViewAutoresizing.FlexibleBottomMargin,UIViewAutoresizing.FlexibleRightMargin]
        self.addSubview(self._activityIndicatorView)
        self._activityIndicatorView.hidesWhenStopped = true
    }
    
    // - GCD
    
    func getDispatchTimeByDate(date: NSDate) -> dispatch_time_t {
        let interval = date.timeIntervalSince1970
        var second = 0.0
        let subsecond = modf(interval, &second)
        var time = timespec(tv_sec: __darwin_time_t(second), tv_nsec: (Int)(subsecond * (Double)(NSEC_PER_SEC)))
        return dispatch_walltime(&time, 0)
    }
    
    //获取Global Dispatch Queue
    let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    // 同步锁
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
