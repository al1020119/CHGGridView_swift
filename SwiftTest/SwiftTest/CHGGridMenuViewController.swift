//
//  CHGGridMenuViewController.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/19.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class CHGGridMenuViewController: UIViewController,CHGGridViewDataSource {
    
    @IBOutlet var chgMenu:CHGMenuView?
    var columns = 2
    var rows = 2
    var lineWidth = 1
    var aroundLine:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        chgMenu?.gridViewDataSource = self;
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
        
    }
    
    func simaluData() -> NSArray {
        let data:NSMutableArray = NSMutableArray()
        for i in 0 ..< columns * rows * 4{
            data[i] = i
        }
        data.add("测试")
        return data
    }
    
    @IBAction func menuMode(sender:AnyObject)->Void {
        chgMenu?.menuViewShowMode = CHGMenuViewShowMode.Menu
        chgMenu?.isCycleShow = true
        chgMenu?.reloadData()
    }
    
    @IBAction func adMode(sender:AnyObject)->Void {
        chgMenu?.menuViewShowMode = CHGMenuViewShowMode.Ad
        chgMenu?.reloadData()
    }
    
    @IBAction func navMode(sender:AnyObject)->Void {
        chgMenu?.menuViewShowMode = CHGMenuViewShowMode.Navigation
        chgMenu?.reloadData()
    }
    
    @IBAction func showPageControl()->Void {
        chgMenu?.isShowPageControl = !(chgMenu?.isShowPageControl)!
        chgMenu?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///返回GridView中的rows
    func numberOfRows(inGridView gridView:AnyObject) -> NSInteger {
        return rows
    }
    ///返回GridView中的columns
    func numberOfColumns(inGridView gridView:AnyObject) -> NSInteger {
        return columns
    }
    ///返回cell
    func cell(forGridView gridView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell {
        if position % 2 == 0 {
            let cell:MyCHGGridViewCell = (gridView as! CHGGridView).dequeueReusableCellWithIdentifier(identifier: "MyCHGGridViewCell", withPosition: position) as! MyCHGGridViewCell
            cell.label?.text = String(describing: data)
            return cell
        } else {
            let cell:MyCHGGridViewCell2 = (gridView as! CHGGridView).dequeueReusableCellWithIdentifier(identifier: "MyCHGGridViewCell2", withPosition: position) as! MyCHGGridViewCell2
            cell.label?.text = String(describing: data)
            return cell
        }
    }

}
