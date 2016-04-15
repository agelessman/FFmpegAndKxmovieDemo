//
//  CellConfigurator.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//


protocol CellConfiguratorType {
    
    var reuseIdentifier: String { get }
    
    var cellClass: AnyClass { get }
    
    
    func updateCell(cell: UITableViewCell)
}


/**
 *  cell 配置器， 这个是跟cell解耦的，为了获取我们需要的数据，然后调用遵守规则cell的协议方法
  *  我们在管理数据的时候，应该把数据封装成一个一个的 此配置器
 */
class CellConfigurator<Cell where Cell: Updataable , Cell: UITableViewCell>: NSObject {
    
    var viewModel: Cell.ViewModel! = nil
    
    let reuseIdentifier: String = NSStringFromClass(Cell.self)
    
    let cellClass: AnyClass = Cell.self
    

    
    init(viewModel: Cell.ViewModel) {
    
      super.init()
      self.viewModel = viewModel
    
    }
    
    

    /**
     外部方位的方法，用于更新规则内的cell的数据
     */
    func updateCell(cell: UITableViewCell) {
       
        if let myCell = cell as? Cell {
             
            myCell.updateWithViewModel(self.viewModel)
        }
    }
    
}

extension CellConfigurator: CellConfiguratorType {
    
}