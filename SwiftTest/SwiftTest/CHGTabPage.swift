//
//  CHGTabPage.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/20.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

///CHGTab在CHGTabPage中的位置
enum CHGTabLocation {
    case Top
    case Down
}

protocol CHGTabPageDataSource:CHGTabDataSource {
    ///返回Page的cell
    func cell(forGridView gridView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell
}

class CHGTabPage: UIView ,CHGGridViewDataSource,CHGTabDelegate{

    var gridView:CHGGridView?
    ///滚动试图
    var tab:CHGTab?
    ///CHGTab在CHGTabPage中的位置
    var tabLocation:CHGTabLocation = CHGTabLocation.Top
    ///tab的高度
    var tabHeight:CGFloat = 0
    var spacing:CGFloat = 0
    
    ///cell之间的间隔
    var intervalOfCell:CGFloat = 0
    ///隐藏周围的线条
    var roundLineShow:Bool = false
    var data:NSArray?
    
    var tabPageDataSource:CHGTabPageDataSource?
    
    ///item的宽度模式
    var tabItemLayoutMode:CHGTabItemLayoutMode = CHGTabItemLayoutMode.AverageWidth
    ///滑块的位置
    var sliderLocation:CHGSliderLocation = CHGSliderLocation.Down
    
    var isCycleShow:Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createView()
    }
    
    func createView() -> Void {
        self.gridView = CHGGridView()
        self.addSubview(gridView!)
        
        self.tab = CHGTab()
        self.addSubview(tab!)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.initView()
        gridView?.addObserver(tab!, forKeyPath: "curryPage", options: NSKeyValueObservingOptions.new, context: nil)
        gridView?.gridViewScrollDelegate = tab
    }
 
    func initView() -> Void {
        
        tab?.backgroundColor = UIColor.white
        tab?.data = data
        tab?.tabDataSource = tabPageDataSource
        tab?.tabDelegate = self
        tab?.tabItemLayoutMode = tabItemLayoutMode
        tab?.sliderLocation = sliderLocation
        tab?.spacing = spacing
        tab?.isCycleShow = isCycleShow
        
        tab?.frame = CGRect(x: 0, y: tabLocation == CHGTabLocation.Top ? 0 : self.frame.height - tabHeight, width: self.frame.width, height: tabHeight)
        gridView?.frame = CGRect(x: 0, y: tabLocation == CHGTabLocation.Top ? tabHeight : 0, width: self.frame.width, height: self.frame.height - tabHeight)
        gridView?.data = data
        gridView?.intervalOfCell = intervalOfCell
        gridView?.roundLineShow = roundLineShow
        gridView?.isPagingEnabled = true
        gridView?.backgroundColor = self.backgroundColor
        gridView?.gridViewDataSource = self;
        gridView?.isCycleShow = isCycleShow///关闭循环功能
        gridView?.isTimerShow = false///关闭定时器
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.initView()
    }
    
    func reloadData() -> Void {
        self.initView()
        gridView?.reloadData()
        tab?.relaodData()
    }
    
    ///注册cell的nib文件
    func registerNibName(nibName:NSString, forCellReuseIdentifier identifier:NSString) -> Void {
        gridView?.registerNibName(nibName: nibName, forCellReuseIdentifier: identifier)
    }
    
    ///通过标识符以及当前position获取cell
    func dequeueReusableCellWithIdentifier(identifier:NSString, withPosition position:NSInteger) -> CHGGridViewCell {
        return (gridView?.dequeueReusableCellWithIdentifier(identifier: identifier, withPosition: position))!
    }
    
    ///返回GridView中的rows
    func numberOfRows(inGridView gridView:AnyObject) -> NSInteger {
        return 1
    }
    
    ///返回GridView中的columns
    func numberOfColumns(inGridView gridView:AnyObject) -> NSInteger {
        return 1
    }
    
    ///返回cell
    func cell(forGridView gridView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell {
        return (tabPageDataSource?.cell(forGridView: gridView, itemAtIndex: position, withData: data))!
    }
    
    func tabItemTap(position:NSInteger) -> Void {
        gridView?.scroll2Page(page: position - 1, animated: true)
    }

}
