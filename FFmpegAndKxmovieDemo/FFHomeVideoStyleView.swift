//
//  FFHomeVideoStyleView.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/14.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFHomeVideoStyleView: UIView {

    
    var MyLayout: VideoLayout!
    var cell: FFHomeCell!

    var shouldPaly: Bool = false
    
    var contentView: UIView!
    var profileView: FFHomeProfileView!
    var textLabel :YYLabel!               // 文本
    
    var videoImageView: FFControl!
    
    var playCountLabel: YYLabel!  // 播放次数
    var playDurationLabel: YYLabel!  // 播放时长
    var playImageView: UIImageView!
    var indicatorView: UIActivityIndicatorView!
    
    var videoPlayView: FFVideoPlayView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.exclusiveTouch = true
        self.backgroundColor = kFFCellBackgroundColor
        
        self.setupContentView()
        self.setupProfileView()
        self.setupTextLabel()
        self.setupVideoImageView()
        self.setupPlayCountAndDurationLabel()
        self.setupPlayImageView()
        self.setupIndicatorView()
        self.setupVideoPlayView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     绑定布局模型数据
     */
    func bindLayout(layout: VideoLayout) {
    
        self.MyLayout = layout
        
        var top: CGFloat = 0
        
        // 设置自身高度
        self.height =  layout.height
        self.width = kScreenWidth
        
        // 设置背景
        self.contentView.top = layout.topMargin
        self.contentView.height = layout.height - layout.topMargin - layout.bottomMargin
        
        // 设置用户资料
        self.profileView.top = top
        self.profileView.height = layout.profileHeight
        
        //设置头像的数据
        
        var iconUrl = ""
        if  layout.videoItem.u?.header?.count > 0 {
            
            iconUrl = layout.videoItem.u!.header!.first!
        }
        let avarUrl = NSURL(string: iconUrl)
       self.profileView.avatarView.yy_setImageWithURL(avarUrl, placeholder: nil, options: YYWebImageOptions.SetImageWithFadeAnimation, progress: nil, transform: { (image, url) -> UIImage? in
        
              let  tempImage = image.yy_imageByResizeToSize(CGSizeMake(40, 40), contentMode: UIViewContentMode.Center)
              return tempImage?.yy_imageByRoundCornerRadius(4)
        }, completion: nil)
        
        
        // 设置徽章
        self.configureAvatarBadgeView()
        
        self.profileView.nameLabel.textLayout = layout.nameTextLayout
        
        self.profileView.sourceLabel.textLayout = layout.sourceTextLayout
        
        self.profileView.moreView.right = self.profileView.width - kFFCellPadding
      
        top += self.profileView.height
        
        self.textLabel.top        = top
        self.textLabel.height     = layout.textHeight
        self.textLabel.textLayout = layout.textLayout!
        
        top += layout.textHeight + kFFCellTopMargin
        
        self.videoImageView.top = top
        self.videoImageView.height = layout.videoImageViewHeight
        
        var videoUrl = ""
        if  layout.videoItem.video?.thumbnail?.count > 0 {
            
            videoUrl = layout.videoItem.video!.thumbnail!.first!
        }
        
        self.videoImageView.layer.yy_setImageWithURL(NSURL(string: videoUrl), placeholder: nil, options: YYWebImageOptions.SetImageWithFadeAnimation, progress: nil, transform: { (image, url) -> UIImage? in
            return image
            }, completion: nil)
        
        self.playCountLabel.bottom = self.videoImageView.height
        if let playCountTextLayout = layout.playCountTextLayout {
            
            self.playCountLabel.width = playCountTextLayout.textBoundingSize.width
            self.playCountLabel.textLayout = playCountTextLayout
        }
        
        self.playDurationLabel.bottom = self.videoImageView.height
        
        if let durationTextLayout = layout.playDurationTextLayout {
            
            self.playDurationLabel.width = durationTextLayout.textBoundingSize.width
            self.playDurationLabel.textLayout = durationTextLayout
            self.playDurationLabel.right = self.videoImageView.width
        }
        
        self.playImageView.centerX = self.videoImageView.width / 2
        self.playImageView.centerY = self.videoImageView.height / 2
        
        
        self.indicatorView.centerX = self.playImageView.centerX
        self.indicatorView.centerY = self.playImageView.centerY
        
        self.videoPlayView.frame = self.videoImageView.frame
    }
    
    
    //MARK: - init method
    func setupContentView() {
        
        self.contentView = UIView()
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.contentView)
        
        self.contentView.width = kScreenWidth
    }
    
    func setupProfileView() {
        
        self.profileView = FFHomeProfileView()
        self.contentView.addSubview(self.profileView)
        self.profileView.width = kScreenWidth
    }
    
    func setupTextLabel()  {
        
        textLabel                             = YYLabel()
        textLabel.left                        = kFFCellPadding
        textLabel.width                       = kFFCellContentWidth
        textLabel.textVerticalAlignment       = YYTextVerticalAlignment.Top
        textLabel.displaysAsynchronously      = true
        textLabel.ignoreCommonProperties      = true
        textLabel.fadeOnAsynchronouslyDisplay = false
        textLabel.fadeOnHighlight             = false
        self.contentView!.addSubview(textLabel)
    }
    
    func setupVideoImageView() {
        
        self.videoImageView             = FFControl()
        self.videoImageView.left = kFFCellPadding
        self.videoImageView.width = kFFCellContentWidth
        self.videoImageView.hidden          = false
        self.videoImageView.clipsToBounds   = true
        self.videoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.videoImageView.backgroundColor = kFFCellHighlightColor
        self.videoImageView.exclusiveTouch  = true
        self.videoImageView.touchBlock = { (view :FFControl,  state :UIGestureRecognizerState, touches :NSSet , even :UIEvent) -> Void in
 
            if state == UIGestureRecognizerState.Ended {
                
                // 加载数据，成功后跳转
                if self.shouldPaly {
                    
                    return
                }
                self.shouldPaly = true
                
                self.playImageView.hidden = true
                self.indicatorView.startAnimating()
                
                var paramers: Dictionary<String,AnyObject> = Dictionary()
                
                if let url = self.MyLayout.videoItem.video?.video?.first {
                    
                    let pathUrl = NSURL(string: url)
                    
                    if pathUrl!.pathExtension == "wmv" {
                        
                        paramers[KxMovieParameterMinBufferedDuration] = (5.0)
                    }
                    
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
                        
                        paramers[KxMovieParameterDisableDeinterlacing] = (true)
                    }
                }
                
           
                
                self.videoPlayView.loadVideoWithPath(self.MyLayout.videoItem.video?.video?.first, parameters: paramers, completionHandler: { (isSuccess) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if isSuccess {
                            
                            self.clear()
                            self.videoImageView.hidden = true
                            self.videoPlayView.hidden = false
                        }
                        else {
                            
                            self.clear()
                        }
                    })
                  
                })
                
            
//                if let delegate = self.cell.delegate {
//                    
//                    delegate.cellDidClickPlay(self.cell)
//                }
            }
          
        }
        self.contentView!.addSubview(self.videoImageView)
    }
    
    func setupPlayCountAndDurationLabel() {
        
        playCountLabel                             = YYLabel()
        playCountLabel.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        playCountLabel.left                        = 0
        playCountLabel.height = kFFPlayCountLabelHeight
        playCountLabel.textVerticalAlignment       = YYTextVerticalAlignment.Center
        playCountLabel.displaysAsynchronously      = true
        playCountLabel.ignoreCommonProperties      = true
        playCountLabel.fadeOnAsynchronouslyDisplay = false
        playCountLabel.fadeOnHighlight             = false
        self.videoImageView!.addSubview(playCountLabel)
        
        playDurationLabel                             = YYLabel()
        playDurationLabel.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        playDurationLabel.height = kFFPlayCountLabelHeight
        playDurationLabel.textVerticalAlignment       = YYTextVerticalAlignment.Center
        playDurationLabel.displaysAsynchronously      = true
        playDurationLabel.ignoreCommonProperties      = true
        playDurationLabel.fadeOnAsynchronouslyDisplay = false
        playDurationLabel.fadeOnHighlight             = false
        self.videoImageView!.addSubview(playDurationLabel)
        
    }
    
    func setupPlayImageView() {
        
        playImageView = UIImageView()
        playImageView.image = FFHelper.imageNamed("video-play")
        playImageView.width = 71
        playImageView.height = playImageView.width
        self.videoImageView.addSubview(playImageView)
    }
    
    func setupIndicatorView() {
        
        self.indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.indicatorView.width = 40
        self.indicatorView.height = self.indicatorView.width
        self.videoImageView.addSubview(self.indicatorView)
        self.indicatorView.hidesWhenStopped = true
    }
    
    func setupVideoPlayView() {
        
        self.videoPlayView = FFVideoPlayView(frame: CGRectZero)
        self.contentView.addSubview(self.videoPlayView)
        self.videoPlayView.hidden = true
    }
    
    
    func configureAvatarBadgeView() {
        
        if let user = self.MyLayout.videoItem.u {
            
            switch user.verifyType {
            case .Vip :
                self.profileView.avatarBadgeView.hidden = false
                self.profileView.avatarBadgeView.image = FFHelper.imageNamed("Profile_AddV_authen")
                
            case .Standard :
                self.profileView.avatarBadgeView.hidden = false
                self.profileView.avatarBadgeView.image = FFHelper.imageNamed("Profile_AddV_authen")
            default :
                self.profileView.avatarBadgeView.hidden = true
            }
        }
    }
    
    func clear() {
        
        self.shouldPaly = false
        self.hidden = false
        self.playImageView.hidden = false
        self.indicatorView.stopAnimating()
        self.videoImageView.hidden = false
        self.videoPlayView.hidden = true
        
    }
}
