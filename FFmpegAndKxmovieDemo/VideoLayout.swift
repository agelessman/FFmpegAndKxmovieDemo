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
let kFFCellBottomMargin: CGFloat = 1   // cell 底部留白

let kFFCellPadding: CGFloat = 12   // cell 内边距
let kFFCellProfileHeight: CGFloat = 56   // cell 头部高度

let kFFCellNamePaddingLeft: CGFloat = 14   // cell 名字和 avatar 之间留白
let kFFCellContentWidth: CGFloat = kScreenWidth - 2 * kFFCellPadding   // cell 内容宽度
let kFFCellNameWidth: CGFloat = kScreenWidth - 110   // cell 名字最宽限制


let kFFCellNameFontSize: CGFloat = 16      // 名字字体大小
let kFFCellSourceFontSize: CGFloat = 12    // 来源字体大小
let kFFCellTextFontSize: CGFloat = 17      // 文本字体大小



// 颜色
let kFFCellNameNormalColor = UIColor(hexString: "333333")// 名字颜色
let kFFCellNameOrangeColor = UIColor(hexString: "f26220") // 橙名颜色 (VIP)
let kFFCellTimeNormalColor = UIColor(hexString: "828282") // 时间颜色
let kFFCellTimeOrangeColor = UIColor(hexString: "f28824") // 橙色时间 (最新刷出)

let kFFCellBackgroundColor = UIColor(hexString: "f2f2f2")    // Cell背景灰色



class VideoLayout: NSObject {

    var videoItem: FFVideoItem!
    
    var height: CGFloat = 0   // cell的总高度
    var topMargin: CGFloat = kFFCellTopMargin  // 顶部灰色留白
    var bottomMargin: CGFloat = kFFCellBottomMargin
    
    var profileHeight: CGFloat = 0
    
    
    var nameTextLayout :YYTextLayout?// 名字
    var sourceTextLayout :YYTextLayout?  //时间
}
