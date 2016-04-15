//
//  Updataable.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//


/**
 *  定义一个协议，包含cell需要的数据模型，这个模型可以是任何类型
 *  定义一个方法，这个方法用来根据不同的模型，更新cell的内容
 */
protocol Updataable  {
    
    associatedtype ViewModel
    
    func updateWithViewModel(viewModel: ViewModel)
    
}
