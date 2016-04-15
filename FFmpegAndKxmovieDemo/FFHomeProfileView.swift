//
//  FFHomeProfileView.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/14.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFHomeProfileView: UIView {

     var avatarView :UIImageView! // 头像
     var avatarBadgeView :UIImageView!
     var nameLabel :YYLabel!
     var sourceLabel :YYLabel!
     var moreView: UIButton!
    
    
    override init(frame: CGRect) {
        
       super.init(frame: frame)
        
        self.exclusiveTouch = true
        self.backgroundColor = UIColor.whiteColor()
        
        //头像
        avatarView = UIImageView()
        avatarView.backgroundColor = UIColor.whiteColor()
        avatarView.size = CGSizeMake(30, 30)
        avatarView.origin = CGPointMake(kFFCellPadding, kFFCellPadding)
        avatarView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(avatarView)
        
        //添加徽章
        avatarBadgeView = UIImageView()
        avatarBadgeView.backgroundColor = UIColor.whiteColor()
        avatarBadgeView.size = CGSizeMake(10, 10)
        avatarBadgeView.center = CGPointMake(avatarView.right - 4, avatarView.bottom - 4)
        avatarBadgeView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(avatarBadgeView)
        
        
        //姓名
        nameLabel = YYLabel()
        nameLabel.backgroundColor = UIColor.whiteColor()
        nameLabel.size = CGSizeMake(kFFCellNameWidth, 24)
        nameLabel.left = avatarView.right + kFFCellNamePaddingLeft
        nameLabel.centerY = 20
        nameLabel.displaysAsynchronously = true
        nameLabel.ignoreCommonProperties = true //这个属性是yykit中专有属性，当为真的时候，对label用layout布局，为假时，响应其他属性
        nameLabel.fadeOnAsynchronouslyDisplay = false
        nameLabel.fadeOnHighlight = false
        nameLabel.lineBreakMode = NSLineBreakMode.ByClipping
        nameLabel.textVerticalAlignment = YYTextVerticalAlignment.Center
        self.addSubview(nameLabel)
        
        //时间和来源
        sourceLabel = YYLabel()
        sourceLabel.backgroundColor = UIColor.whiteColor()
        sourceLabel.frame = nameLabel.frame
        sourceLabel.centerY = 40
        sourceLabel.displaysAsynchronously = true
        sourceLabel.ignoreCommonProperties = true //这个属性是yykit中专有属性，当为真的时候，对label用layout布局，为假时，响应其他属性
        sourceLabel.fadeOnAsynchronouslyDisplay = false
        sourceLabel.fadeOnHighlight = false
 
        self.addSubview(sourceLabel)
        
        moreView = UIButton()
        moreView.size = CGSizeMake(40, 40)
        moreView.centerY = 25
        moreView.backgroundColor = UIColor.whiteColor()
        moreView.setImage(FFHelper.imageNamed("cellmorebtnnormal"), forState: UIControlState.Normal)
        moreView.setImage(FFHelper.imageNamed("cellmorebtnnormalN"), forState: UIControlState.Highlighted)
        self.addSubview(moreView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
