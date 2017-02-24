//
//  CHGMenuView.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/19.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

///CHGMenu显示模式
enum CHGMenuViewShowMode {
    case Menu       //菜单模式
    case Ad         //广告模式此模式下每一页只有一个item
    case Navigation //应用首次开启时候的引导模式 和广告模式相比不会自动展示下一页
}

///CHGMenuView 的代理方法
protocol CHGMenuViewDelegate {
    ///当item被点击的时候回掉
    func menuView(menuView:CHGMenuView, didSelecteAtIndex position:NSInteger) -> Void
}

///CHGMenuView的dataSource
protocol CHGMenuViewDataSource {
    ///返回CHGMenuView中的rows
    func numberOfRows(inCHGMenuView menuView:AnyObject) -> NSInteger
    ///返回CHGMenuView中的columns
    func numberOfColumns(inCHGMenuView menuView:AnyObject) -> NSInteger
    ///返回cell
    func cell(forCHGMenuView menuView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell
}

class CHGMenuView: UIView,CHGGridViewDataSource,CHGGridViewDelegate{

    var gridView:CHGGridView?
    ///pageControl
    var pageControl:UIPageControl?
    ///是否显示pageControl
    var isShowPageControl:Bool = true
    ///cell之间的间隔
    var intervalOfCell:CGFloat = 0
    ///隐藏周围的线条
    var roundLineShow:Bool = false
    ///gridView的datasource
    var menuViewDataSource:CHGMenuViewDataSource?
    ///delegate
    var menuViewDelegate:CHGMenuViewDelegate?
    ///自动展示的时间间隔
    var timeInterval:NSInteger = 5
    ///cell的数据
    var data:NSArray?
    ///是否循环显示
    var isCycleShow:Bool = true
    ///pageControl 选择的颜色
    var currentPageIndicatorTintColor:UIColor = UIColor.orange
    ///pageControl未选择颜色
    var pageIndicatorTintColor:UIColor = UIColor.gray
    ///显示模式，默认为菜单模式
    var menuViewShowMode:CHGMenuViewShowMode = CHGMenuViewShowMode.Menu
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createView()
    }
    
    ///创建view
    func createView() -> Void {
        self.gridView = CHGGridView()
        self.pageControl = UIPageControl()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.addSubview(gridView!)
        gridView?.addObserver(self, forKeyPath: "curryPage", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.addSubview(pageControl!)
        self.initView()
    }
 
    func initView() -> Void {
        pageControl?.isHidden = !isShowPageControl
        gridView?.data = data
        gridView?.intervalOfCell = intervalOfCell
        gridView?.roundLineShow = roundLineShow
        gridView?.isPagingEnabled = true
        gridView?.backgroundColor = self.backgroundColor
        gridView?.gridViewDelegate = self
        
        pageControl?.currentPage = (gridView?.curryPage)!
        pageControl?.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        pageControl?.pageIndicatorTintColor = pageIndicatorTintColor
        pageControl?.isUserInteractionEnabled = false
        
        if menuViewShowMode == CHGMenuViewShowMode.Menu {
            gridView?.gridViewDataSource = self;
            gridView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - (isShowPageControl ? 30 : 0))
            gridView?.isCycleShow = isCycleShow
            gridView?.timeInterval = timeInterval
            
            pageControl?.numberOfPages = self.calculateMaxPage(useColuns: (self.numberOfColumns(inGridView: gridView!)), andRows: (self.numberOfRows(inGridView: gridView!)), withCellCount: (data?.count)!)
            pageControl?.frame = CGRect(x: 0, y: self.frame.height - 30, width: self.frame.width, height: 30)
        } else if menuViewShowMode == CHGMenuViewShowMode.Ad {
            gridView?.gridViewDataSource = self;
            gridView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gridView?.isCycleShow = isCycleShow
            gridView?.isTimerShow = true///开启定时器
            gridView?.timeInterval = timeInterval
            
            pageControl?.numberOfPages = self.calculateMaxPage(useColuns: (self.numberOfColumns(inGridView: gridView!)), andRows: (self.numberOfRows(inGridView: gridView!)), withCellCount: (data?.count)!)
            pageControl?.frame = CGRect(x: 0, y: self.frame.height - 30, width: self.frame.width, height: 30)
        } else if menuViewShowMode == CHGMenuViewShowMode.Navigation {
            gridView?.gridViewDataSource = self;
            gridView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gridView?.isCycleShow = false///关闭循环功能
            gridView?.isTimerShow = false///关闭定时器
            gridView?.timeInterval = timeInterval
            
            pageControl?.numberOfPages = self.calculateMaxPage(useColuns: (self.numberOfColumns(inGridView: gridView!)), andRows: (self.numberOfRows(inGridView: gridView!)), withCellCount: (data?.count)!)
            pageControl?.frame = CGRect(x: 0, y: self.frame.height - 30, width: self.frame.width, height: 30)
        }
    }
    
    func reloadData() -> Void {
        self.initView()
        gridView?.reloadData()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "curryPage" {
            let curryPage = (gridView?.curryPage)!
            pageControl?.currentPage = (gridView?.isCycleShow)! ? curryPage - 1 : curryPage
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.initView()
    }
    
    ///计算总共有几页
    func calculateMaxPage(useColuns colunns:NSInteger, andRows rows:NSInteger, withCellCount cellCount:NSInteger) -> NSInteger {
        return gridView!.calculateMaxPage(useColuns: colunns, andRows: rows, withCellCount: cellCount,isContainsCyclePage: false)
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
        return menuViewShowMode != CHGMenuViewShowMode.Menu ? 1 : (menuViewDataSource?.numberOfRows(inCHGMenuView: self))!
    }
    ///返回GridView中的columns
    func numberOfColumns(inGridView gridView:AnyObject) -> NSInteger {
        return menuViewShowMode != CHGMenuViewShowMode.Menu ? 1 : (menuViewDataSource?.numberOfColumns(inCHGMenuView: self))!
    }
    ///返回cell
    func cell(forGridView gridView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell {
        return (menuViewDataSource?.cell(forCHGMenuView: self, itemAtIndex: position, withData: data))!
    }
    
    
    func gridView(gridView:CHGGridView, didSelecteAtIndex position:NSInteger) -> Void {
        menuViewDelegate?.menuView(menuView: self, didSelecteAtIndex: position)
    }
    
}
