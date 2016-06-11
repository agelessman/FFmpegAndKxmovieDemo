//
//  FFLabel.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/6/6.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

class FFLabel: UILabel {

    func illuminatedString(text: String , font: UIFont) -> NSAttributedString {
        
        let len = text.characters.count
        
        // create a mutable str
        let mutaString = NSMutableAttributedString(string: text)
        
        let corlor = UIColor.whiteColor()
        
        mutaString.addAttribute(NSForegroundColorAttributeName, value: corlor, range: NSMakeRange(0, len))
        mutaString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, len))
        
        return mutaString
    }
    
    
    override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(ctx)
        
        CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);//4
        
        CGContextTranslateCTM(ctx, 0, rect.size.height);//3
        
        CGContextScaleCTM(ctx, 1.0, -1.0);//2
        
        CGContextTranslateCTM(ctx, -rect.origin.x, -rect.origin.y);//1
        
//        CGContextRotateCTM(ctx, CGFloat(M_PI))
        
        let text = illuminatedString(self.text!, font: self.font)
        
        let line = CTLineCreateWithAttributedString(text as CFAttributedString)
        
        let  r = text.boundingRectWithSize(self.frame.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        CGContextSetTextPosition(ctx, 0.0, self.frame.size.height / 2 - r.size.height / 2)
        
        CTLineDraw(line, ctx!)
        
        CGContextRestoreGState(ctx)
        
        
        
    }
}
