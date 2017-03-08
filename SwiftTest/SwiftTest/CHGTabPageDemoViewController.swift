//
//  CHGTabPageDemoViewController.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/20.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class CHGTabPageDemoViewController: UIViewController,CHGTabPageDataSource,CHGTabPageViewDelegate {
    
    @IBOutlet var tabPage:CHGTabPage?
    
    var sliderHeight:CGFloat = 1
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tabPage?.tabHeight = 45                         //Tab的高度
        tabPage?.tabPageDataSource = self               //代理
        tabPage?.tabPageViewDelegate = self
        tabPage?.registerNibName(nibName: "MyCHGGridViewCell", forCellReuseIdentifier: "MyCHGGridViewCell")//注册nib文件， 类似 UITableViewCell 的用法 ,优化性能能
        tabPage?.registerNibName(nibName: "MyCHGGridViewCell2", forCellReuseIdentifier: "MyCHGGridViewCell2")
        tabPage?.data = simaluData()//添加数据，这里的数据可以自己定义
        tabPage?.tabLocation = CHGTabLocation.Top
        tabPage?.tabItemLayoutMode = CHGTabItemLayoutMode.AutoWidth
        tabPage?.backgroundColor = UIColor.groupTableViewBackground
        tabPage?.spacing = 5                            //Tab中item的间距
        tabPage?.sliderLocation = CHGSliderLocation.Down//设置Tab中滑块的位置CHGSliderLocation.Down 表示滑块在item的底部。CHGSliderLocation.Top表示滑块在item的顶部
        tabPage?.isCycleShow = true                     //设置是否可以循环显示
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
//    func cell(forTabPage gridView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell {
    func cell(forTabPage tabPage: CHGTabPage, itemAtIndex position: NSInteger, withData data: AnyObject) -> CHGGridViewCell {
        ///
//        if position % 2 == 0 {
            let cell:MyCHGGridViewCell = tabPage.dequeueReusableCellWithIdentifier(identifier: "MyCHGGridViewCell", withPosition: position) as! MyCHGGridViewCell
            cell.label?.text = String(describing: data)
            return cell
//        } else {
//            let cell:MyCHGGridViewCell2 = tabPage.dequeueReusableCellWithIdentifier(identifier: "MyCHGGridViewCell2", withPosition: position) as! MyCHGGridViewCell2
//            cell.label?.text = String(describing: data)
//            return cell
//        }
    }
    
    ///返回TabItem, 可以继承CHGTabItem类
//    func tab(tab:CHGTab,itemAtIndex position:NSInteger,withData data:AnyObject) -> CHGTabItem {
    func tabPage(tabPage: CHGTabPage, itemAtIndex position: NSInteger, withData data: AnyObject) -> CHGTabItem {
        let tabItem:CHGTabItem = CHGTabItem.initWithNibName(nibName: "TabItem1")
        tabItem.setItemData(data: data,position: position)
//        tabItem.backgroundColor = position%2 == 0 ? UIColor.yellow : UIColor.blue
        return tabItem
    }
    
    ///滑块的高度
//    func tabSliderHeight(tab:CHGTab) -> CGFloat{
    func tabPageSliderHeight(tabPage: CHGTabPage) -> CGFloat {
        if tabPage.tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth {
            return 0
        }
        return sliderHeight
    }
    
    ///返回滑块 可以继承CHGSlider类自定义个性的滑块
//    func tabSlider() -> CHGSlider{
    func tabPageSlider(tabPage: CHGTabPage) -> CHGSlider {
        let slider:MySlider = MySlider.initWithNibName(nibName: "MySlider") as! MySlider
        return slider
    }
    
    ///获取tab的宽度 tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth 有用
//    func tabScrollWidth(tab:CHGTab,withPosition position:NSInteger,withData data:AnyObject) -> CGFloat{
    func tabPageScrollWidth(tabPage: CHGTabPage, withPosition position: NSInteger, withData data: AnyObject) -> CGFloat {
        let str:NSString = data as! NSString
        return CGFloat(str.length) * 25
    }
    
    func leftView(inTabPageView tabPage: CHGTabPage) -> UIView? {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        btn.backgroundColor = UIColor.red
        btn.setTitle("左边", for: UIControlState.normal)
        return btn
    }
    
    func rightView(inTabPageView tabPage: CHGTabPage) -> UIView? {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        btn.backgroundColor = UIColor.green
        btn.setTitle("右边", for: UIControlState.normal)
        return btn
    }
    
    func tabPage(tabPage:CHGTabPage, pageDidChangeWithPage page:NSInteger, withCell cell:CHGGridViewCell) -> Void {
        let cell_:MyCHGGridViewCell = cell as! MyCHGGridViewCell
        
        print("page:\(page)    text:\(cell_.label?.text)")
    }

}
