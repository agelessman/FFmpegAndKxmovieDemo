//
//  FFTextLinePositionModifier.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/17.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//


/**
 文本 Line 位置修改
 将每行文本的高度和位置固定下来，不受中英文/Emoji字体的 ascent/descent 影响
 */

/*
 将每行的 baseline 位置固定下来，不受不同字体的 ascent/descent 影响。
 
 注意，Heiti SC 中，    ascent + descent = font size，
 但是在 PingFang SC 中，ascent + descent > font size。
 所以这里统一用 Heiti SC (0.86 ascent, 0.14 descent) 作为顶部和底部标准，保证不同系统下的显示一致性。
 间距仍然用字体默认
 */

class FFTextLinePositionModifier: NSObject,YYTextLinePositionModifier {

    var font :UIFont? // 基准字体 (例如 Heiti SC/PingFang SC)
    var paddingTop :CGFloat?  //文本顶部留白
    var paddingBottom :CGFloat?  //文本底部留白
    var lineHeightMultiple :CGFloat? //行距倍数
    
    override init() {
        
        super.init()
        if UIDevice.systemVersion() >= 9 {
            lineHeightMultiple = 1.34  // for PingFang SC
        }else{
            lineHeightMultiple = 1.3125 // for Heiti SC
        }
        
    }
    
    func modifyLines(lines: [YYTextLine], fromText text: NSAttributedString, inContainer container: YYTextContainer) {
        
        //CGFloat ascent = _font.ascender;
        let ascent = font!.pointSize * 0.86
        
        let lineHeight = font!.pointSize * lineHeightMultiple!
        
        //目的是实现调整所有的baseline的计算
        for line :YYTextLine in lines {
            
            var position = line.position
            position.y = paddingTop! + ascent + CGFloat(line.row) * lineHeight
            line.position = position
        }
        
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let one = FFTextLinePositionModifier()
        one.font = font
        one.paddingTop = paddingTop
        one.paddingBottom = paddingBottom
        one.lineHeightMultiple = lineHeightMultiple
        return one
    }
    
    func heightForLineCount(lineCount :Int) -> CGFloat {
        if (lineCount == 0)  {return 0};
        //    CGFloat ascent = _font.ascender;
        //    CGFloat descent = -_font.descender;
        let ascent = font!.pointSize * 0.86;
        let descent = font!.pointSize * 0.14;
        let lineHeight = font!.pointSize * lineHeightMultiple!;
        return paddingTop! + paddingBottom! + ascent + descent + CGFloat(lineCount - 1) * lineHeight;
    }
}
