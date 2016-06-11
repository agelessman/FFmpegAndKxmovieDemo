//
//  FFSlider.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/6/4.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

class FFSlider: UISlider {

    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        
        return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 5)
    }

}
