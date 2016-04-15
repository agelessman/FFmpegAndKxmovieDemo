//
//  FFHomeCell.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class FFHomeCell: BasicTableViewCell {

    var viewModel: VideoLayout?
    
    var videoContentView: FFHomeVideoStyleView!   ///  视频播放的总容器
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
       super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.videoContentView = FFHomeVideoStyleView()
        self.videoContentView.cell = self
        self.contentView.addSubview(self.videoContentView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWithViewModel(viewModel: VideoLayout) {
        
        self.viewModel = viewModel
        
       let layout = viewModel
        
        self.height = layout.height
        self.contentView.height = layout.height
        
        self.videoContentView.bindLayout(layout)
    }
}


extension FFHomeCell: Updataable {
    
    typealias ViewModel = VideoLayout
}