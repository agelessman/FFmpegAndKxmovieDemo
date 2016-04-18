//
//  ViewController.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/12.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit
import Alamofire

let videoCellId = "videoCellId"

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    var tableView: UITableView!
    
    var dataController: FFHomeDataController!
    
    var refreshView: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.dataController = FFHomeDataController()
        
        self.setupTableView()
        
        self.setupRefreshView()
       
        // init datas
        self.fetchDatas()
        
        let fps = MCFPSLabel()
        fps.size = CGSizeMake(60, 30)
        fps.bottom = self.view.bottom
        self.view.addSubview(fps)
  
    }

    func fetchDatas() {
        
        let url = "http://d.api.budejie.com/topic/list/chuanyue/41/baisi_xiaohao-iphone-4.1/0-200.json?appname=baisi_xiaohao&asid=8C66099E-C265-4990-B8EE-8A002E4D84D0&client=iphone&device=iPhone%204S&from=ios&jbk=0&mac=&market=&openudid=f5ff7b5919088e7d120443fcb85a4bc259cc515b&udid=&ver="

        self.dataController.fetchHomeListWithUrl(url) { (response, errorMsg) in
            
            self.tableView.reloadData()
            self.refreshView.endRefreshing()
        }
    }

    func setupTableView() {
        
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.top = 20
        self.tableView.height -= 20
        self.view.addSubview(self.tableView)
        
//        // 这个便利注册，有点问题，待优化
//        for item in self.dataController.list {
//            
//            self.tableView.registerClass(item.cellClass, forCellReuseIdentifier: item.reuseIdentifier)
//        }
        
    }
    
    func setupRefreshView() {
        
        self.refreshView = UIRefreshControl()
        self.refreshView.addTarget(self, action: #selector(ViewController.fetchDatas), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshView)
    }
    
    
    //MARK: - tableView delegate dataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataController.list.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let videoLayout = self.dataController.list[indexPath.row]
        return videoLayout.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = self.dataController.list[indexPath.row]

        var cell = tableView.dequeueReusableCellWithIdentifier(videoCellId) as? FFHomeCell
        
        if cell == nil {

            cell = FFHomeCell(style: UITableViewCellStyle.Default, reuseIdentifier: videoCellId)
            cell?.delegate = self
        }
        cell?.indexPath = indexPath
        cell!.updateWithViewModel(item)
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let homeCell = cell as? FFHomeCell {
            
            homeCell.clear()
        }
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    //MARK: - private method
    func pushToVideoPlayControllerWithIndexPath(indexPath: NSIndexPath) {
        
        var paramers: Dictionary<String,AnyObject> = Dictionary()
        
        let video = self.dataController.list[indexPath.row]
        
        var url :String?
        
        
        url = video.videoItem.video?.video?.first
        
        
        if url == nil {
            
            return
        }
        
        let path: String = url!
        
        let pathUrl = NSURL(string: path)
        
        if let _ = pathUrl {
            
            if pathUrl!.pathExtension == "wmv" {
                
                paramers[KxMovieParameterMinBufferedDuration] = (5.0)
            }
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
                
                paramers[KxMovieParameterDisableDeinterlacing] = (true)
            }
            print(pathUrl!.scheme)
            let playVc = KxMovieViewController.movieViewControllerWithContentPath(path, parameters: paramers) as! UIViewController
            
            self.presentViewController(playVc, animated: true, completion: nil)
        }
    }
    
}


extension ViewController: FFHomeCellDelegate {
    
    func cellDidClickPlay(cell: FFHomeCell) {
        
        self.pushToVideoPlayControllerWithIndexPath(cell.indexPath)
    }
}
