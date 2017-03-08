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
    case Top        //设置Tab的位置，CHGTabLocation.Top 表示Tab在整个view的顶部现实
    case Down       //CHGTabLocation.Down 则在整个view的底部显示
}



///CHGTabPage的DataSource
protocol CHGTabPageDataSource {
    ///返回TabItem
    func tabPage(tabPage:CHGTabPage,itemAtIndex position:NSInteger,withData data:AnyObject) -> CHGTabItem
    ///滑块的高度
    func tabPageSliderHeight(tabPage:CHGTabPage) -> CGFloat
    ///返回滑块
    func tabPageSlider(tabPage:CHGTabPage) -> CHGSlider
    ///获取tab的宽度 tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth 有用
    func tabPageScrollWidth(tabPage:CHGTabPage,withPosition position:NSInteger,withData data:AnyObject) -> CGFloat
    ///返回Page的cell
    func cell(forTabPage tabPage:CHGTabPage, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell
    ///添加左边view
    func leftView(inTabPageView tabPage:CHGTabPage) -> UIView?
    ///在右边天加一个view
    func rightView(inTabPageView tabPage:CHGTabPage) -> UIView?
}

protocol CHGTabPageViewDelegate {
    
    func tabPage(tabPage:CHGTabPage, pageDidChangeWithPage page:NSInteger, withCell cell:CHGGridViewCell) -> Void
}

class CHGTabPage: UIView ,CHGGridViewDataSource,CHGTabDelegate,CHGTabDataSource,CHGGridViewScrollDelegate{

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
    
    var tabPageViewDelegate:CHGTabPageViewDelegate?
    
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
    }
    
    
 
    func initView() -> Void {
        
        let leftView = tabPageDataSource?.leftView(inTabPageView: self)
        let rightView = tabPageDataSource?.rightView(inTabPageView: self)
        
        tab?.backgroundColor = self.backgroundColor
        tab?.data = data
        tab?.tabDataSource = self
        tab?.tabDelegate = self
        tab?.tabItemLayoutMode = tabItemLayoutMode
        tab?.sliderLocation = sliderLocation
        tab?.spacing = spacing
        tab?.isCycleShow = isCycleShow
//        tab?.frame = CGRect(x: 0, y: tabLocation == CHGTabLocation.Top ? 0 : self.frame.height - tabHeight, width: self.frame.width, height: tabHeight)
        if leftView != nil {
            leftView?.frame = CGRect(x: 0,
                                     y: tabLocation == CHGTabLocation.Top ? 0 : self.frame.height - tabHeight,
                                     width: (leftView?.frame.width)!,
                                     height: (leftView?.frame.height)!)
            self.addSubview(leftView!)
        }
        
        if rightView != nil {
            rightView?.frame = CGRect(x: self.frame.width - (rightView?.frame.width)!,
                                      y: tabLocation == CHGTabLocation.Top ? 0 : self.frame.height - tabHeight,
                                      width: (rightView?.frame.width)!,
                                      height: (rightView?.frame.height)!)
            self.addSubview(rightView!)
        }
        tab?.frame = CGRect(x: leftView == nil ? 0 : (leftView?.frame.width)!,
                            y: tabLocation == CHGTabLocation.Top ? 0 : self.frame.height - tabHeight,
                            width: self.frame.width - (leftView == nil ? 0 : (leftView?.frame.width)!) - (rightView == nil ? 0 : (rightView?.frame.width)!),
                            height: tabHeight)
        
        gridView?.frame = CGRect(x: 0, y: tabLocation == CHGTabLocation.Top ? tabHeight : 0, width: self.frame.width, height: self.frame.height - tabHeight)
        gridView?.data = data
        gridView?.intervalOfCell = intervalOfCell
        gridView?.roundLineShow = roundLineShow
        gridView?.isPagingEnabled = true
        gridView?.backgroundColor = self.backgroundColor
        gridView?.gridViewDataSource = self;
        gridView?.gridViewScrollDelegate = self
        gridView?.isCycleShow = isCycleShow///关闭循环功能
        gridView?.isTimerShow = false///关闭定时器
    }
    
    func reloadData() -> Void {
        self.initView()
        gridView?.reloadData()
        tab?.relaodData()
    }
    
    ///注册nib文件， 类似 UITableViewCell 的用法
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
        return (tabPageDataSource?.cell(forTabPage: self, itemAtIndex: position, withData: data))!
//        return (tabPageDataSource?.cell(forGridView: gridView, itemAtIndex: position, withData: data))!
    }
    
    ///点击tab的item回掉
    func tabItemTap(position:NSInteger) -> Void {
        gridView?.scroll2Page(page: position - 1, animated: true)
    }
    
    
    ///返回TabItem
    func tab(tab:CHGTab,itemAtIndex position:NSInteger,withData data:AnyObject) -> CHGTabItem {
        return (tabPageDataSource?.tabPage(tabPage: self, itemAtIndex: position, withData: data))!
    }
    ///滑块的高度
    func tabSliderHeight(tab:CHGTab) -> CGFloat {
        return (tabPageDataSource?.tabPageSliderHeight(tabPage: self))!
    }
    ///返回滑块
    func tabSlider() -> CHGSlider {
        return (tabPageDataSource?.tabPageSlider(tabPage: self))!
    }
    ///获取tab的宽度 tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth 有用
    func tabScrollWidth(tab:CHGTab,withPosition position:NSInteger,withData data:AnyObject) -> CGFloat{
        return (tabPageDataSource?.tabPageScrollWidth(tabPage: self, withPosition: position, withData: data))!
    }
    
    
    
    ///手指开始拖动
    func gridViewWillBeginDragging(_ gridView: CHGGridView)->Void {
        tab?.gridViewWillBeginDragging(gridView)
    }
    
    ///手指结束拖动
    func gridViewDidEndDragging(_ gridView: CHGGridView, willDecelerate decelerate: Bool)->Void {
        tab?.gridViewDidEndDragging(gridView, willDecelerate: decelerate)
    }
    
    ///已经结束减速
    func gridViewDidEndDecelerating(_ gridView: CHGGridView)->Void {
        tab?.gridViewDidEndDecelerating(gridView)
    }
    
    ///滑动中
    func gridViewDidScroll(_ gridView: CHGGridView)->Void {
        tab?.gridViewDidScroll(gridView)
    }
    
    func gridViewDidEndScrollingAnimation(_ gridView: CHGGridView)->Void {
        tab?.gridViewDidEndScrollingAnimation(gridView)
    }
    
    ///scrollView 停止滑动
    func scrollViewDidStop(gridView:CHGGridView) -> Void{
        tab?.scrollViewDidStop(gridView: gridView)
        let page = gridView.curryPageReal//isCycleShow ? gridView.curryPage - 1 : gridView.curryPage
        tabPageViewDelegate?.tabPage(tabPage: self, pageDidChangeWithPage: page, withCell: (tabPageDataSource?.cell(forTabPage: self, itemAtIndex: page, withData: data?.object(at: page) as AnyObject))!)
    }
    
    func getCurryPageReal() -> NSInteger {
        return (gridView?.curryPageReal)!
    }
}
