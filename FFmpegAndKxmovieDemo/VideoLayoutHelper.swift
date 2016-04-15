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
        
        self.layout.height = 80
        
        
        self._layoutProfile()
        
      
        return self.layout
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
    print(createTime)
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
