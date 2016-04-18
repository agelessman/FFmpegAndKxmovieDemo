//
//  VideoLayoutHelper.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/14.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//


 /// 视频模型 -----》 带布局的模型

class VideoLayoutHelper: NSObject {


    var layout: VideoLayout = VideoLayout()
    
    func transformVideoItem(video: FFVideoItem) -> VideoLayout {

        self.layout.videoItem = video
        
        self.layout.height = 0
        
        
        self._layoutProfile()
        
        self._layoutTextLabel()
        
        self._layoutViewImageView()
        
        self._layoutPlayCountAndDuration()

        self.layout.height += self.layout.topMargin
        self.layout.height += self.layout.profileHeight
        
        self.layout.height += self.layout.textHeight
        
        self.layout.height += self.layout.videoImageViewHeight
        
        self.layout.height += self.layout.bottomMargin
        
        self.layout.height += self.layout.bottomMargin
    
        return self.layout
    }

    //MARK: - 计算播放次数和时长的布局
    func _layoutPlayCountAndDuration () {
        
        if let count = self.layout.videoItem.video?.playcount {
            
            let countText: NSMutableAttributedString = NSMutableAttributedString(string: "\(count)播放")
            countText.yy_font = UIFont.systemFontOfSize(kFFCellPlayCountTextFontSize)
            countText.yy_color = UIColor.whiteColor()
            
            let container = YYTextContainer()
            container.size = CGSizeMake(kFFCellContentWidth, CGFloat(MAXFLOAT))
            
            self.layout .playCountTextLayout = YYTextLayout(container: container, text: countText)

        }
        
        if let duration = self.layout.videoItem.video?.duration {
            
            let hour = duration / 60 / 60 % 60
            
            let secondStr = String(format: "%0.2i", duration % 60)
            let minuteStr = String(format: "%0.2i", duration / 60 % 60)
            let hourStr = String(format: "%0.2i", duration / 60 / 60 % 60)
           
            let time = hour > 0 ? hourStr + ":" + minuteStr + ":" + secondStr : minuteStr + ":" + secondStr
            
            let durationText: NSMutableAttributedString = NSMutableAttributedString(string: time)
            durationText.yy_font = UIFont.systemFontOfSize(kFFCellPlayCountTextFontSize)
            durationText.yy_color = UIColor.whiteColor()
            
            
            let container = YYTextContainer()
            container.size = CGSizeMake(kFFCellContentWidth, CGFloat(MAXFLOAT))
            
            self.layout .playDurationTextLayout = YYTextLayout(container: container, text: durationText)
            
        }
        
    }
    
    //MARK: - 计算播放大小
    func _layoutViewImageView () {
        
        var tempHeight: CGFloat = 0
        var tempWidth: CGFloat = 1
        var videoW: CGFloat = 0
        var videoH: CGFloat = 0
        
        if let h = self.layout.videoItem.video?.height {
            
            tempHeight = h
        }
        
        if let w = self.layout.videoItem.video?.width {
            
            tempWidth = w
        }
        
        // 视频宽度超过屏幕宽度 
        if tempWidth >= kFFCellContentWidth {
            
            // 视频的宽度就是kFFCellContentWidth
            videoW = kFFCellContentWidth
   
            videoH = tempHeight / tempWidth * kFFCellContentWidth // 按比例计算高度
            
             if videoH > kFFVideoMaxHeight {  // 超高了，重新计算宽度
            
                videoH = kFFVideoMaxHeight
                videoW = videoH * tempWidth / tempHeight
            }

        }
        else {  // 宽度未超过kFFCellContentWidth
            
            if tempHeight >= tempWidth {  // 高度大于 宽度， 优先考虑高度
                
                if tempHeight > kFFVideoMaxHeight { // 若大于最大允许的高度，取最大高度
                    
                    videoH = kFFVideoMaxHeight
                }
                else {
                    
                    videoH = tempHeight
                }
                
                videoW = videoH * tempWidth / tempHeight
                
            }
            else { // 宽度大于高度
                
                videoH = tempHeight
                videoW = tempWidth
            }
        }
        
       self.layout.videoImageViewHeight = videoH
        self.layout.videoWidth = videoW
        self.layout.videoHeight = videoH
        
    }
    
    //MARK: - 计算正文
    func _layoutTextLabel() {
        
        if  let textStr = self.layout.videoItem.text {
            
            let text: NSMutableAttributedString = NSMutableAttributedString(string: textStr)
            text.yy_font = UIFont.systemFontOfSize(kFFCellTextFontSize)
            text.yy_color = kFFCellTextNormalColor
            
            let modifier = FFTextLinePositionModifier()
            modifier.font = UIFont(name: "Heiti SC", size: kFFCellTextFontSize )
            modifier.paddingTop = 0
            modifier.paddingBottom = kFFCellPaddingText / 2
            
            let container = YYTextContainer()
            container.size = CGSizeMake(kFFCellContentWidth, CGFloat(MAXFLOAT))
            container.linePositionModifier = modifier
            
            self.layout .textLayout = YYTextLayout(container: container, text: text)
            if self.layout .textLayout == nil { return }
            
            self.layout.textHeight = modifier.heightForLineCount((self.layout.textLayout?.lines.count)!)
        }
        
        
    }
    
    //MARK:计算头像，名字，时间
    func _layoutProfile()
    {
        self._layoutName()
        self._layoutSource()
        self.layout.profileHeight = kFFCellProfileHeight
    }
    
    
    //MARK:计算名字的布局
    func _layoutName()
    {
        var nameStr: String = ""
        
        if self.layout.videoItem.u != nil && self.layout.videoItem.u!.name != nil {
            
            nameStr = self.layout.videoItem.u!.name!
        }

        let nameText = NSMutableAttributedString(string: nameStr)

        nameText.yy_font = UIFont.systemFontOfSize(kFFCellNameFontSize)
        
        if let u = self.layout.videoItem.u {
            
            switch u.verifyType {
            case .None:
                nameText.yy_color = kFFCellNameNormalColor
            default:
                nameText.yy_color = kFFCellNameOrangeColor
            }
        }

        nameText.yy_lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        let container = YYTextContainer(size: CGSizeMake(kFFCellNameWidth, 999.0))
        container.maximumNumberOfRows = 1
        self.layout.nameTextLayout = YYTextLayout(container: container, text: nameText)
        
    }
    
    
    //MARK:计算时间和来源
    func _layoutSource()
    {
        let sourceText = NSMutableAttributedString()
        
        let createTime = FFHelper.stringWithTimelineDate(self.layout.videoItem.passtime)

        //时间
        if let _ = createTime {
            let timeText = NSMutableAttributedString(string: createTime!)
            timeText.yy_appendString(" ")
            timeText.yy_font = UIFont.systemFontOfSize(kFFCellSourceFontSize)
            timeText.yy_color = kFFCellTimeNormalColor
            sourceText.appendAttributedString(timeText)
        }
      
        
        if sourceText.length == 0 { self.layout.sourceTextLayout = nil }
        else{
            
            let container = YYTextContainer(size: CGSizeMake(kFFCellNameWidth, 9999))
            container.maximumNumberOfRows = 1
            self.layout.sourceTextLayout = YYTextLayout(container: container, text: sourceText)
        }
        
    }
}
