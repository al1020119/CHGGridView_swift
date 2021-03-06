//
//  CHGGridMenuViewController.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/19.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class CHGGridMenuViewController: UIViewController,CHGMenuViewDataSource,CHGMenuViewDelegate {
    
    @IBOutlet var chgMenu:CHGMenuView?
    var columns = 2
    var rows = 2
    var lineWidth = 1
    var aroundLine:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        chgMenu?.menuViewDataSource = self
        chgMenu?.menuViewDelegate = self
        chgMenu?.data = self.simaluData()
        chgMenu?.registerNibName(nibName: "MyCHGGridViewCell", forCellReuseIdentifier: "MyCHGGridViewCell")
        chgMenu?.registerNibName(nibName: "MyCHGGridViewCell2", forCellReuseIdentifier: "MyCHGGridViewCell2")
        chgMenu?.intervalOfCell = CGFloat(lineWidth)
        chgMenu?.roundLineShow = aroundLine
        chgMenu?.currentPageIndicatorTintColor = UIColor.red
        chgMenu?.pageIndicatorTintColor = UIColor.white
        chgMenu?.isShowPageControl = true
        chgMenu?.isCycleShow = true
        chgMenu?.menuViewShowMode = CHGMenuViewShowMode.Menu
        chgMenu?.timeInterval = 5//广告模式下 5秒切换一次
        
        
    }
    
    func simaluData() -> NSArray {
        let data:NSMutableArray = NSMutableArray()
//        for i in 0 ..< columns * rows * 4{
//            data[i] = i
//        }
        data.add("头条")
        data.add("要闻")
        data.add("娱乐")
        data.add("热点")
        data.add("体育")
        data.add("上海")
        data.add("视频")
        data.add("网易号")
        data.add("财经")
        data.add("轻松一刻")
        return data
    }
    
    ///设置为菜单模式
    @IBAction func menuMode(sender:AnyObject)->Void {
        chgMenu?.menuViewShowMode = CHGMenuViewShowMode.Menu
        chgMenu?.isCycleShow = true
        chgMenu?.reloadData()
    }
    
    ///设置为广告模式
    @IBAction func adMode(sender:AnyObject)->Void {
        chgMenu?.menuViewShowMode = CHGMenuViewShowMode.Ad
        chgMenu?.reloadData()
    }
    
    ///设置为导航模式
    @IBAction func navMode(sender:AnyObject)->Void {
        chgMenu?.menuViewShowMode = CHGMenuViewShowMode.Navigation
        chgMenu?.reloadData()
    }
    
    ///设置pageControl是否显示
    @IBAction func showPageControl()->Void {
        chgMenu?.isShowPageControl = !(chgMenu?.isShowPageControl)!
        chgMenu?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///返回GridView中的rows
    func numberOfRows(inCHGMenuView menuView:AnyObject) -> NSInteger {
        return rows
    }
    ///返回GridView中的columns
    func numberOfColumns(inCHGMenuView menuView:AnyObject) -> NSInteger {
        return columns
    }
    ///返回cell
    func cell(forCHGMenuView menuView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell {
        if position % 2 == 0 {
            let cell:MyCHGGridViewCell = (menuView as! CHGMenuView).dequeueReusableCellWithIdentifier(identifier: "MyCHGGridViewCell", withPosition: position) as! MyCHGGridViewCell
            cell.label?.text = String(describing: data)
            return cell
        } else {
            let cell:MyCHGGridViewCell2 = (menuView as! CHGMenuView).dequeueReusableCellWithIdentifier(identifier: "MyCHGGridViewCell2", withPosition: position) as! MyCHGGridViewCell2
            cell.label?.text = String(describing: data)
            return cell
        }
    }
    
    ///当item被点击的时候回掉
    func menuView(menuView:CHGMenuView, didSelecteAtIndex position:NSInteger,withData data:AnyObject) -> Void {
        print("position=\(position)")
    }

}
