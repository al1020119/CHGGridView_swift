//
//  CHGGridView.swift
//  SwiftTest
//
//  Created by Hogan on 2017/2/17.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

///GridView的DataSource
protocol CHGGridViewDataSource :NSObjectProtocol {
    ///返回GridView中的rows
    func numberOfRows(inGridView gridView:AnyObject) -> NSInteger
    ///返回GridView中的columns
    func numberOfColumns(inGridView gridView:AnyObject) -> NSInteger
    ///返回cell
    func cell(forGridView gridView:AnyObject, itemAtIndex position:NSInteger, withData data:AnyObject) -> CHGGridViewCell
}

///CHGGridView滑动delegate
protocol CHGGridViewScrollDelegate {
    ///手指开始拖动
    func gridViewWillBeginDragging(_ gridView: CHGGridView)
    ///手指结束拖动
    func gridViewDidEndDragging(_ gridView: CHGGridView, willDecelerate decelerate: Bool)
    ///已经结束减速
    func gridViewDidEndDecelerating(_ gridView: CHGGridView)
    ///滑动中
    func gridViewDidScroll(_ gridView: CHGGridView)
    
    func gridViewDidEndScrollingAnimation(_ gridView: CHGGridView)
    ///scrollView 停止滑动
    func scrollViewDidStop(gridView:CHGGridView) -> Void
}

///滑动方向判断
enum ScrollDirection {
    case stop   ///滑动停止
    case left   ///向左滑动
    case right  ///向右滑动
}

///CHGGridView 主要实现横向的网格试图， 具有定时滚动，循环滚动 动态添加网格数量等功能
class CHGGridView: UIScrollView,UIScrollViewDelegate{
    ///DataSource数据源
    weak open var gridViewDataSource: CHGGridViewDataSource?
    ///一页最多能显示的cell数量
    var maxCellsOfOnePage:NSInteger = 0
    /// 一页中最多的列数
    var maxColumnsOfOnePage:NSInteger = 0
    /// 一页中最多的行数
    var maxRowsOfOnePage:NSInteger = 0
    ///总共页数
    var pageCount:NSInteger = 0
    ///cell的高度
    var cellHeight:CGFloat = 0
    ///cell的宽度
    var cellWidth:CGFloat = 0
    ///cell之间的间隔
    var intervalOfCell:CGFloat = 0
    ///隐藏周围的线条
    var roundLineShow:Bool = false
    ///存放所有cell对象的字典，字典通过identifier获取CHGGridViewCell数组
    var queue:NSMutableDictionary = NSMutableDictionary()
    ///保存identifier  所有注册的cell 类
    var identifiersDic:NSMutableDictionary = NSMutableDictionary()
    ///当前显示的页面
    dynamic var curryPage:NSInteger = 0
    ///是否显示页面分割线
    var isShowPageDivider:Bool = false
    ///是否循环显示
    var isCycleShow:Bool = true
    ///缓存页数
    var cacheCount:NSInteger = 2
    ///是否定时滚动显示
    var isTimerShow:Bool = false
    ///定时间隔
    var timeInterval:NSInteger = 1
    ///定时器
    var timer:Timer?
    ///CHGGridView滑动delegate
    var gridViewScrollDelegate:CHGGridViewScrollDelegate?
    
    ///cell的数据
    var data:NSArray?
    var _data: NSArray {
        get {
            return self.data!
        }
        set {
            self.data = newValue
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //设置的颜色不生效，此处调用一次解决
        self.backgroundColor = self.backgroundColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.delegate = self
        self.initView()
        if isCycleShow {
            self.scroll2Page(page: 1, animated: false)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(CHGGridView.onScreenRound), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        self.startTimer()
    }
    
    
    ///屏幕旋转
    func onScreenRound() -> Void {

    }
    
    func initView() -> Void {
//        self.isPagingEnabled = true
        //获取单页中最大列数
        let maxColumnsOfOnePageTemp:NSInteger = (gridViewDataSource?.numberOfColumns(inGridView: self))!
        //获取单页中最大行数
        let maxRowsOfOnePageTemp:NSInteger = (gridViewDataSource?.numberOfRows(inGridView: self))!
        var reSize = true
        if maxColumnsOfOnePageTemp != maxColumnsOfOnePage || maxRowsOfOnePageTemp != maxRowsOfOnePage {
            reSize = false
            maxColumnsOfOnePage = maxColumnsOfOnePageTemp
            maxRowsOfOnePage = maxRowsOfOnePageTemp
            self.removeSubviews()
        }
        //获取cell的高度
        cellHeight = (self.frame.size.height - intervalOfCell * CGFloat(roundLineShow ? maxRowsOfOnePage + 1 : maxRowsOfOnePage - 1)) / CGFloat(maxRowsOfOnePage);
        //获取cell的宽度
        cellWidth = (self.frame.size.width - intervalOfCell * CGFloat(roundLineShow ? maxColumnsOfOnePage + (isShowPageDivider ? 1 : 0) : maxColumnsOfOnePage - 1)) / CGFloat(maxColumnsOfOnePage);
        //获取1页中cell的最大数量(可能)
        maxCellsOfOnePage = maxColumnsOfOnePage * maxRowsOfOnePage;
        //获取最多有几页
        pageCount = self.calculateMaxPage(useColuns: maxColumnsOfOnePage, andRows: maxRowsOfOnePage, withCellCount: (data?.count)!,isContainsCyclePage: isCycleShow)
        //初始化所有注册的cell
        if !reSize {
            self.createAllRegisterCellType()
        }
        self.contentSize = CGSize(width: Int(self.frame.size.width) * pageCount, height: 1)
        self.createCellsOfPage(page: curryPage,isResize: reSize)
    }
    
    ///移除所有view
    func removeSubviews() -> Void {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    func reloadData() -> Void {
        self.initView()
        self.startTimer()
    }
    
    ///开始定时器
    func startTimer() -> Void {
        ///启动定时器
        if isTimerShow {
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: true) { (Timer) in
                    print("a")
                    let curryPageTemp:NSInteger = self.curryPage + 1
                    self.scroll2Page(page: curryPageTemp >= self.pageCount ? 0 : curryPageTemp, animated: true)
                }
            }
        } else {
            if timer != nil {
                self.closeTimer()
            }
        }
    }
    
    ///关闭定时器
    func closeTimer() -> Void {
        if timer != nil {
            timer?.invalidate();
            timer = nil
        }
    }
    
    ///暂停定时器
    func suspendedTimer() -> Void {
        if timer != nil {
            timer?.fireDate = NSDate.distantPast;
        }
    }
    
    ///滑动到指定页面
    func scroll2Page(page:NSInteger,animated:Bool) -> Void {
        let rect = CGRect(x: self.frame.width * CGFloat(page), y: 0, width: self.frame.width, height: self.frame.height)
        self.scrollRectToVisible(rect, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if maxColumnsOfOnePage != 0 {
            initView()
        }
    }
    
    ///创建指定页面的cell
    func createCellsOfPage(page:NSInteger, isResize:Bool) -> Void {
        if page >= pageCount || page < 0 {
            return
        }
        var columTemp:NSInteger = -1
        for i in 0 ..< self.calculateCountOfCell(inPage: page) {
            if i % self.maxColumnsOfOnePage == 0 {
                columTemp += 1
            }
            self.createViewWithIndex(i: i, withColumn: columTemp, inPage: page,isResize: isResize)
        }
    }
    
    ///创建cell
    func createViewWithIndex(i:NSInteger, withColumn column:NSInteger, inPage page:NSInteger, isResize:Bool) -> Void {
        var ii = i + maxCellsOfOnePage * page
        if isCycleShow {
            if page + 1 == pageCount { ///最后一页 应该拿第一页的数据
                ii = i
            } else if page == 0 {
                ii = i + maxCellsOfOnePage * (pageCount - 3)
            } else {
                ii = i + maxCellsOfOnePage * (page - 1)
            }
        }
        if gridViewDataSource == nil {
            return
        }
        let cell:CHGGridViewCell = (gridViewDataSource?.cell(forGridView: self, itemAtIndex: ii, withData: data?.object(at: ii) as AnyObject))!
        cell.frame = self.calculateFrameWithPosition(position: ii, andColumn: column, andPage: page)
        cell.tag = ii
        if !isResize {
            self.addSubview(cell)
        }
    }
    
    ///计算cell的frame
    func calculateFrameWithPosition(position:NSInteger, andColumn column:NSInteger, andPage page:NSInteger) -> CGRect {
        let y_:NSInteger = column % maxRowsOfOnePage
        let y:CGFloat = CGFloat(y_)*CGFloat(cellHeight) + intervalOfCell * (column == 0 && !roundLineShow ? 0 : CGFloat(column + (roundLineShow ? 1 : 0)))
        
        let x:CGFloat = CGFloat((position % maxColumnsOfOnePage)) * CGFloat(cellWidth) + CGFloat(page) * CGFloat(self.frame.size.width) + intervalOfCell * CGFloat(position % maxColumnsOfOnePage == 0 && !roundLineShow ? 0 : position % maxColumnsOfOnePage + (roundLineShow ? 1 : 0))
        
        return CGRect(x: x, y: y, width: CGFloat(cellWidth), height: CGFloat(cellHeight))
    }
    
    ///注册cell的nib文件
    func registerNibName(nibName:NSString, forCellReuseIdentifier identifier:NSString) -> Void {
        identifiersDic.setObject(nibName, forKey: identifier)
    }
    
    ///通过标识符以及当前position获取cell
    func dequeueReusableCellWithIdentifier(identifier:NSString, withPosition position:NSInteger) -> CHGGridViewCell {
        let cells:NSArray = queue.object(forKey: identifier) as! NSArray
        let p:NSInteger = curryPage % cacheCount
        let cell:CHGGridViewCell = cells.object(at: position % maxCellsOfOnePage + maxCellsOfOnePage * /*(2-*/p/*)*/) as! CHGGridViewCell
        return cell
    }
    
    ///创建所有注册的cell的nib
    func createAllRegisterCellType() -> Void {
        let identifiers:NSArray = identifiersDic.allKeys as NSArray
        for i in 0 ..< identifiers.count {
            self.createSomeCellWithNib(nib: identifiersDic.object(forKey: identifiers.object(at: i)) as! NSString,
                                       withCellReuseIdentifier: identifiers.object(at: i) as! NSString)
        }
    }
    
    ///通过nib 和 identifier创建2页数量的cell
    func createSomeCellWithNib(nib:NSString, withCellReuseIdentifier identifier:NSString) -> Void {
        let cells:NSMutableArray = NSMutableArray()
        for _ in 0 ..< cacheCount {///创建2页cell
            for _ in 0 ..< maxCellsOfOnePage {
                cells.add(CHGGridViewCell.initWithNibName(nibName: nib))
            }
        }
        queue.setObject(cells, forKey: identifier)
    }
    
    ///计算总共有几页
    func calculateMaxPage(useColuns colunns:NSInteger, andRows rows:NSInteger, withCellCount cellCount:NSInteger, isContainsCyclePage:Bool) -> NSInteger {
        var page:Int = 0
        if colunns * rows == 0 {
            return 0
        }
        if cellCount % (colunns * rows) == 0 {
            page = cellCount / (colunns * rows)
        } else {
            let temp:Float = Float(cellCount) / Float(colunns * rows) + 1
            page = Int(floorf(temp))
        }
        
        if isContainsCyclePage {
            page += isCycleShow ? 2 : 0     //如果需要循环显示则增加2页  分别是首页放在最后一页后面， 最后一页放在首页前面
        }
        return page
    }

    ///计算指定页面总共有多少cell
    func calculateCountOfCell(inPage page:NSInteger) -> NSInteger {
        if isCycleShow { ///如果循环显示， 第0页应该给最后一页的数量，如果是最后一页的数据则返回第一页的数量
            if page == 0 { ///返回最后一页的数量
                return (data?.count)! - (pageCount - 3) * maxCellsOfOnePage
            } else if pageCount - 2 ==  page {
                return (data?.count)! - (pageCount - 3) * maxCellsOfOnePage
            } else {
                return maxCellsOfOnePage > (data?.count)! ?  (data?.count)! : maxCellsOfOnePage
            }
        }
        return page + 1 < pageCount ? maxCellsOfOnePage : (data?.count)! - page * maxCellsOfOnePage
    }
    
    ///上次滑动的位置
    var lastScrollDownX:CGFloat = 0
    ///是否已经结束减速
    var scrollViewDidEndDecelerating:Bool = false
    ///手指结束拖动
    var scrollViewDidEndDragging:Bool = false
    ///滑动方向
    var scrollDirection:ScrollDirection = ScrollDirection.stop
    
    ///手指开始拖动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gridViewScrollDelegate?.gridViewWillBeginDragging(self)
        scrollViewDidEndDragging = false
        scrollViewDidEndDecelerating = false
        if scrollDirection == ScrollDirection.left {
            self.createCellsOfPage(page: curryPage + 1, isResize: false)
        } else if scrollDirection == ScrollDirection.right {
            self.createCellsOfPage(page: curryPage - 1, isResize: false)
        }
    }
    
    ///手指结束拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        gridViewScrollDelegate?.gridViewDidEndDragging(self, willDecelerate: decelerate)
        scrollViewDidEndDragging = true
    }
    
    ///已经结束减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        gridViewScrollDelegate?.gridViewDidEndDecelerating(self)
        self.scrollViewDidStop(scrollView: scrollView)
    }
    
    ///滑动中
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gridViewScrollDelegate?.gridViewDidScroll(self)
        let currScrollX:CGFloat = scrollView.contentOffset.x
        if currScrollX > lastScrollDownX {
//            print("向左边滑动")
            scrollDirection = ScrollDirection.left
            if self.contentOffset.x >= self.frame.width * CGFloat(curryPage) {
                curryPage += 1
                self.createCellsOfPage(page: curryPage, isResize: false)
            }
        } else if currScrollX < lastScrollDownX {
            scrollDirection = ScrollDirection.right
//            print("向右边滑动")
            if self.contentOffset.x <= self.frame.width * CGFloat(curryPage) {
                curryPage -= 1
                self.createCellsOfPage(page: curryPage, isResize: false)
            }
        }
        
        lastScrollDownX = currScrollX
        self.curryPage = lroundf(Float(scrollView.contentOffset.x / self.frame.size.width))
        if isCycleShow {///循环显示
            if curryPage == 0 && self.contentOffset.x <= 0 {///循环页中的第0页
                scrollView.contentOffset = CGPoint(x: self.frame.width * CGFloat(pageCount - 2) + self.contentOffset.x, y: 0)
            } else if curryPage == pageCount - 1 && self.contentOffset.x >= self.frame.width * CGFloat(pageCount - 1){
                let xx = self.contentOffset.x - self.frame.width * CGFloat(pageCount - 1)
                scrollView.contentOffset = CGPoint(x: self.frame.width + xx, y: 0)
            } else if curryPage == 1 && self.contentOffset.x <= self.frame.width {///当页面第一次出现 并且向右边滑动时侯应该创建最后一页数据
                if scrollDirection == ScrollDirection.right {
                    self.createCellsOfPage(page: 0, isResize: false)
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        gridViewScrollDelegate?.gridViewDidEndScrollingAnimation(self)
        self.scrollViewDidStop(scrollView: scrollView)
    }
    
    ///scrollView 停止滑动
    func scrollViewDidStop(scrollView:UIScrollView) -> Void {
        gridViewScrollDelegate?.scrollViewDidStop(gridView: self)
        scrollViewDidEndDecelerating = true
        scrollDirection = ScrollDirection.stop
        //循环滚动逻辑
        if isCycleShow {
            if curryPage == 0 {
                self.scroll2Page(page: pageCount - 2, animated: false)
            } else if curryPage == pageCount - 1 {
                self.scroll2Page(page: 1, animated: false)
            }
        }
    }
}
