//
//  CHGTabPageDemoViewController.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/20.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class CHGTabPageDemoViewController: UIViewController,CHGTabPageDataSource {
    
    @IBOutlet var tabPage:CHGTabPage?
    
    var sliderHeight:CGFloat = 1
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        //Tab的高度
        tabPage?.tabHeight = 45
        //代理
        tabPage?.tabPageDataSource = self
        //注册nib文件， 类似 UITableViewCell 的用法
        tabPage?.registerNibName(nibName: "MyCHGGridViewCell", forCellReuseIdentifier: "MyCHGGridViewCell")
        tabPage?.registerNibName(nibName: "MyCHGGridViewCell2", forCellReuseIdentifier: "MyCHGGridViewCell2")
        //添加数据，这里的数据可以自己定义
        tabPage?.data = ["0","1","2","3","4","5","6","7","8","9","10","11","12","13"]
        //设置Tab的位置，CHGTabLocation.Top 表示Tab在整个view的顶部现实，如果CHGTabLocation.Down 则在整个view的底部显示
        tabPage?.tabLocation = CHGTabLocation.Top
        //设置Tab中的item的宽度，CHGTabItemLayoutMode.AutoWidth表示Tab中的item的宽度由datasource中的方法返回宽度，用户可以使用任意宽度，如果宽度超出屏幕的宽度则可以左右滑动，类似网易新闻中的tab。CHGTabItemLayoutMode.AverageWidth 表示Tab中的item的宽度是屏幕的宽度除以tab的数量
        tabPage?.tabItemLayoutMode = CHGTabItemLayoutMode.AutoWidth
        //Tab中item的间距
        tabPage?.spacing = 5
        //设置Tab中滑块的位置CHGSliderLocation.Down 表示滑块在item的底部。CHGSliderLocation.Top表示滑块在item的顶部
        tabPage?.sliderLocation = CHGSliderLocation.Down
        tabPage?.isCycleShow = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addItem(sender:AnyObject) {
        let data:NSMutableArray = NSMutableArray(array: (tabPage?.data)!)
        data.add("\(data.count)")
        tabPage?.data = data;
        tabPage?.reloadData()
    }
    
    @IBAction func jianItem(sender:AnyObject) {
        let data:NSMutableArray = NSMutableArray(array: (tabPage?.data)!)
        data.removeObject(at: data.count - 1)
        tabPage?.data = data;
        tabPage?.reloadData()
    }
    
    @IBAction func recycleItem(sender:AnyObject) {
        tabPage?.isCycleShow = !(tabPage?.isCycleShow)!
        tabPage?.reloadData()
    }
    
    @IBAction func layoutItem(sender:AnyObject) {
        tabPage?.tabItemLayoutMode = tabPage?.tabItemLayoutMode == CHGTabItemLayoutMode.AverageWidth ? CHGTabItemLayoutMode.AutoWidth : CHGTabItemLayoutMode.AverageWidth
        tabPage?.reloadData()
    }
    
    @IBAction func addSpacing(sender:AnyObject) {
        tabPage?.spacing += 1
        tabPage?.reloadData()
    }

    @IBAction func jianSpacing(sender:AnyObject) {
        tabPage?.spacing -= 1
        tabPage?.reloadData()
    }
    
    
    @IBAction func addSliderHeight(sender:AnyObject) {
        sliderHeight += 1
        tabPage?.reloadData()
    }
    
    @IBAction func jianSliderHeight(sender:AnyObject) {
        sliderHeight -= 1
        if sliderHeight < 0 {
            sliderHeight = 0
        }
        tabPage?.reloadData()
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
    
    ///返回TabItem
    func tab(tab:CHGTab,itemAtIndex position:NSInteger,withData data:AnyObject) -> CHGTabItem {
        let tabItem:CHGTabItem = CHGTabItem.initWithNibName(nibName: "TabItem1")
        tabItem.setItemData(data: data,position: position)
        tabItem.backgroundColor = position%2 == 0 ? UIColor.yellow : UIColor.green
        return tabItem
    }
    
    ///滑块的高度
    func tabSliderHeight(tab:CHGTab) -> CGFloat{
        if tab.tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth {
            return 0
        }
        return sliderHeight
    }
    
    ///返回滑块
    func tabSlider() -> CHGSlider{
        let slider:MySlider = MySlider.initWithNibName(nibName: "MySlider") as! MySlider
        return slider
    }
    
    ///获取tab的宽度 tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth 有用
    func tabScrollWidth(tab:CHGTab,withPosition position:NSInteger) -> CGFloat{
        return position >= 10 ? 80 : 50
    }

}
