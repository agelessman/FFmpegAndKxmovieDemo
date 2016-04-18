//
//  VideoLayout.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/14.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

let kScreenWidth = UIScreen.mainScreen().bounds.size.width
let kScreenHeight = UIScreen.mainScreen().bounds.size.height

let kFFCellTopMargin: CGFloat = 5   // cell 顶部灰色留白
let kFFCellBottomMargin: CGFloat = 3   // cell 底部留白

let kFFCellPadding: CGFloat = 12   // cell 内边距
let kFFCellProfileHeight: CGFloat = 52   // cell 头部高度

let kFFCellNamePaddingLeft: CGFloat = 14   // cell 名字和 avatar 之间留白
let kFFCellContentWidth: CGFloat = kScreenWidth - 2 * kFFCellPadding   // cell 内容宽度
let kFFCellNameWidth: CGFloat = kScreenWidth - 110   // cell 名字最宽限制
let kFFCellPaddingText: CGFloat = 10   // cell 文本与其他元素间留白

let kFFPlayCountLabelHeight: CGFloat = 15   // 播放次数的高度

let kFFCellNameFontSize: CGFloat = 16      // 名字字体大小
let kFFCellSourceFontSize: CGFloat = 12    // 来源字体大小
let kFFCellTextFontSize: CGFloat = 17      // 文本字体大小
let kFFCellPlayCountTextFontSize: CGFloat = 12      // 播放次数字体大小


// 颜色
let kFFCellNameNormalColor = UIColor(hexString: "333333")// 名字颜色
let kFFCellNameOrangeColor = UIColor(hexString: "f26220") // 橙名颜色 (VIP)
let kFFCellTimeNormalColor = UIColor(hexString: "828282") // 时间颜色
let kFFCellTimeOrangeColor = UIColor(hexString: "f28824") // 橙色时间 (最新刷出)

let kFFCellBackgroundColor = UIColor(hexString: "f2f2f2")    // Cell背景灰色

let kFFCellTextNormalColor = UIColor(hexString: "333333") // 一般文本色
let kFFCellHighlightColor = UIColor(hexString: "f0f0f0")     // Cell高亮时灰色

let kFFVideoMaxHeight: CGFloat = 230

class VideoLayout: NSObject {

    var videoItem: FFVideoItem!
    
    var height: CGFloat = 0   // cell的总高度
    var topMargin: CGFloat = kFFCellTopMargin  // 顶部灰色留白
    var bottomMargin: CGFloat = kFFCellBottomMargin
    
    var profileHeight: CGFloat = 0
    
    
    var nameTextLayout :YYTextLayout?// 名字
    var sourceTextLayout :YYTextLayout?  //时间
    
    var textHeight: CGFloat = 0
    var textLayout: YYTextLayout?
    
    var videoImageViewHeight: CGFloat = 0
    
    var videoWidth: CGFloat = 0
    var videoHeight: CGFloat = 0
    
    var playCountTextLayout :YYTextLayout?// 播放次数
    var playDurationTextLayout :YYTextLayout?  //时长
    
}
