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

    var contentView: UIView!
    var profileView: FFHomeProfileView!
    var textLabel :YYLabel!               // 文本
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.exclusiveTouch = true
        self.backgroundColor = kFFCellBackgroundColor
        
        self.setupContentView()
        self.setupProfileView()
        self.setupTextLabel()
        
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
        
        top += layout.textHeight
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
    
}
