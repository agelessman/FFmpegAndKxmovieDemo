//
//  FFHomeDataController.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/13.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//



class HomeListResult: NSObject,Mappable {
    
    var list: [FFVideoItem]?
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        list <- map["list"]
     
    }
}


class FFHomeDataController: FFBasicDataController {


    var list: Array<CellConfiguratorType> = Array()
    
    
    func fetchHomeListWithUrl(url: String , completionHandler: ((AnyObject? , String?) -> Void)?) {
        
        FFBasicRequest.shareInstance.fetchDataWith(url, parameter: nil) { (result, errorMsg) in
            
            let listResult = Mapper<HomeListResult>().map(result)
            
            if let _ = listResult?.list {
              
              
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                
                    for videoItem in listResult!.list! {
                        
                        let model = VideoLayoutHelper().transformVideoItem(videoItem)
                       
                        let con = CellConfigurator<FFHomeCell>(viewModel:model)
                        
                        self.list.append(con)
                        
                    }

                    dispatch_async(dispatch_get_main_queue(), {
                    
                        
                        if let _ = completionHandler {
                            
                            completionHandler!(listResult,errorMsg)
                        }
                        
                        return
                    })
                })
            }
            
            else {
              
                if let _ = completionHandler {
                    
                    completionHandler!(listResult,errorMsg)
                }
            }
            
           
        }
    }
    
}
