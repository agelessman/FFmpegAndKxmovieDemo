//
//  FFHelper.swift
//  FFmpegAndKxmovieDemo
//
//  Created by 马超 on 16/4/15.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

var formatterYesterday : NSDateFormatter?
var formatterSameYear : NSDateFormatter?
var formatterFullDate : NSDateFormatter?

class FFHelper: NSObject {

    
    //MARK: ------- 从 bundle 里获取图片 (有缓存) -------
    class func imageNamed(name :NSString?) -> UIImage?
    {
        if name == nil
        {
            return nil
        }
        
        var image :UIImage?

        
        var ext  = name?.pathExtension
        if ext?.characters.count == 0
        {
            ext = "png"
        }
        
        let path = NSBundle.mainBundle().pathForScaledResource(name! as String, ofType: ext)
        
        
        if path == nil
        {
            return nil
        }
        
        image = imageWithPath(path)
        return image
    }
    
    //MARK: ------- 从path创建图片 (有缓存) ---------
    class func imageWithPath(path :NSString?) -> UIImage?
    {
        if path == nil
        {
            return nil
        }
        var image :UIImage?
        if path?.pathScale() == 1
        {
            // 查找 @2x @3x 的图片
            let scales :Array<NSNumber> = NSBundle.preferredScales()
            for scale :NSNumber in scales
            {
                image = UIImage(contentsOfFile: path!.stringByAppendingPathScale(CGFloat(scale)))
                if let _ = image
                {
                    break
                }
            }
        }else
        {
            image = UIImage(contentsOfFile: path as! String)
        }
        if let _ = image{
            image = image?.yy_imageByDecoded()
//            imageCache().setObject(image, forKey: path!)
        }
        return image
    }
    
    //MARK: ------- 图片 cache --------
    class func imageCache() -> YYMemoryCache
    {
        struct Static {
            
            static let twCache = YYMemoryCache()
            
        }
        
        Static.twCache.shouldRemoveAllObjectsOnMemoryWarning = false
        Static.twCache.shouldRemoveAllObjectsWhenEnteringBackground = false
        Static.twCache.name = "VideoHomeImageCache"
        
        return  Static.twCache
    }
    
    //MARK: ------- 将 date 格式化成的友好显示 ---------
    class func stringWithTimelineDate(date :String?) -> String?
    {
        
        if date == nil { return "" }
        
        let temp = NSDate(string: date!, format: "yy-MM-dd HH:mm:ss")
        if  formatterYesterday == nil {
            formatterYesterday = NSDateFormatter()
            formatterYesterday!.dateFormat = "昨天 HH:mm"
            formatterYesterday!.locale = NSLocale.currentLocale()
        }
        
        if  formatterSameYear == nil {
            formatterSameYear = NSDateFormatter()
            formatterSameYear!.dateFormat = "MM-dd HH:mm"
            formatterSameYear!.locale = NSLocale.currentLocale()
        }
        if  formatterFullDate == nil {
            formatterFullDate = NSDateFormatter()
            formatterFullDate!.dateFormat = "yy-MM-dd HH:mm"
            formatterFullDate!.locale = NSLocale.currentLocale()
        }
        
        
        let now = NSDate()
        let delta :NSTimeInterval = now.timeIntervalSince1970 - temp!.timeIntervalSince1970
        if delta < -60 * 10
        {
            return  formatterFullDate!.stringFromDate(temp!)
        }else if delta < 60 * 10 {
            return "刚刚"
        }else if delta < 60 * 60 {
            return "\(Int(delta / 60.0))分钟前"
        }else if temp!.isToday {
            return "\(Int(delta / 60.0 / 60.0))小时前"
        }else if temp!.isYesterday {
            return formatterYesterday!.stringFromDate(temp!)
        }else if temp!.year == now.year {
            return formatterSameYear!.stringFromDate(temp!)
        }else  {
            return formatterFullDate!.stringFromDate(temp!)
        }
        
    }
}
