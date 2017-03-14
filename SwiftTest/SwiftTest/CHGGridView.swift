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

///GridView的代理
protocol CHGGridViewDelegate {
    ///item被点击
    func gridView(gridView:CHGGridView, didSelecteAtIndex position:NSInteger, withData data:AnyObject) -> Void
    
}

///CHGGridView滑动delegate
protocol CHGGridViewScrollDelegate {
    ///手指开始拖动
    func gridViewWillBeginDragging(_ gridView: CHGGridView)->Void
    ///手指结束拖动
    func gridViewDidEndDragging(_ gridView: CHGGridView, willDecelerate decelerate: Bool)->Void
    ///已经结束减速
    func gridViewDidEndDecelerating(_ gridView: CHGGridView)->Void
    ///滑动中
    func gridViewDidScroll(_ gridView: CHGGridView)->Void
    
    func gridViewDidEndScrollingAnimation(_ gridView: CHGGridView)->Void
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
    open var gridViewDataSource: CHGGridViewDataSource?
    ///CHGGridView的delegate
    open var gridViewDelegate:CHGGridViewDelegate?
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
    dynamic var _curryPage:NSInteger = 0
    var curryPage: NSInteger {
        get {
            return _curryPage
        }
        set {
            _curryPage = newValue
            let curryPageRelTemp:NSInteger = isCycleShow ? _curryPage - 1 : _curryPage
            self.curryPageReal = curryPageRelTemp < 0 ? 0 : curryPageRelTemp
        }
    }
    
    dynamic var curryPageReal:NSInteger = 0
    dynamic var pageCountReal:NSInteger = 0
    ///是否显示页面分割线
    var isShowPageDivider:Bool = false
    ///是否循环显示
    var _isCycleShow:Bool = true
    var isCycleShow: Bool {
        get {
            return _isCycleShow
        }
        set {
            isCycleShowUpdate = newValue != _isCycleShow
            _isCycleShow = newValue
        }
    }
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
    ///标记是否正在创建cell
    var isCreateCells:Bool = false
    
    ///当前正在创建的页面
    var curryCreatedPage:NSInteger = -1
    ///循环状态是否发生改变,  如果是yes 则说明当前 isCycleShow 的值和上次不一样
    var isCycleShowUpdate:Bool = false;
    
    ///记录page   当页面滑动完毕才会变化
    var pageValueMax:NSInteger = 0;
    ///记录page   当页面滑动完毕才会变化
    var pageValueMin:NSInteger = 0;
    ///从左往右滑动轮回开始
    var isRebirthLeft2RightStart:Bool = false
    ///从右往左滑动轮回开始
    var isRebirthRight2LeftStart:Bool = false
    ///从右往左滑动轮回结束
    var isRebirthLeft2RightEnd:Bool = false
    ///从左往右滑动轮回结束
    var isRebirthLeft2LeftEnd:Bool = false
    ///判断当前是否已经布局过
    var isLayoutSubView:Bool = false;
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //设置的颜色不生效，此处调用一次解决
        self.backgroundColor = self.backgroundColor
    }
    
    override func didMoveToSuperview() {
        self.closeTimer()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            self.closeTimer()
        } else {
            self.startTimer()
        }
    }
    
    func initDefaultValues() -> Void {
        curryCreatedPage = -1
        self.timeInterval = 1
        self.isShowPageDivider = false
        self.isCycleShow = true
        self.isTimerShow = false
        
    }
    
    override func layoutSubviews() {
        if !isLayoutSubView {
            isLayoutSubView = true
            pageValueMax = -999
            self.delegate = self
            self.initView(isFromReload: false)
            if data == nil || data?.count == 0 {
                cellHeight = 0
                cellWidth = 0
                return
            }
            self.startTimer()
        }
    }
    
    func initView(isFromReload:Bool) -> Void {
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
        pageCountReal = isCycleShow ? pageCount - 2 : pageCount;
        //初始化所有注册的cell
        if !reSize {
            self.createAllRegisterCellType()
        }
        self.contentSize = CGSize(width: Int(self.frame.size.width) * pageCount, height: 1)
        if data == nil || data?.count == 0 {
            return
        }
        self.curryPage = self.calculateCurryPage(IsFromReload: isFromReload)
        self.createCellsOfPage(page: curryPage, isResize: reSize)
        self.scroll2Page(page: curryPageReal, animated: false)
    }
    
    func calculateCurryPage(IsFromReload:Bool) -> NSInteger {
        var page:NSInteger = 0
        if IsFromReload {
            if isCycleShowUpdate {
                isCycleShowUpdate = false
                if isCycleShow {
                    page = curryPage + 1;
                } else {
                    page = curryPage - 1
                    page = page < 0 ? 0 : page
                }
            } else {
                page = curryPage
            }
        }
        return page
    }
    
    
    func reloadData() -> Void {
        pageValueMax = -999
        self.removeSubviews()
        self.initView(isFromReload: true)
        self.startTimer()
    }
    
    ///开始定时器
    func startTimer() -> Void {
        ///启动定时器
        if isTimerShow {
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: true) { (Timer) in
                    if self.data == nil || self.data?.count == 0 {
                        self.closeTimer()
                        return
                    }
                    let curryPageTemp:NSInteger = self.curryPageReal + 1
                    self.scroll2Page(page: curryPageTemp >= self.pageCount ? 0 : curryPageTemp, animated: true)
                }
            } else {
                
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
        let rect = CGRect(x: self.frame.width * (isCycleShow ? CGFloat(page + 1) : CGFloat(page)), y: 0, width: self.frame.width, height: self.frame.height)
        self.scrollRectToVisible(rect, animated: animated)
    }
    
    ///创建指定页面的cell
    func createCellsOfPage(page:NSInteger, isResize:Bool) -> Void {
//        print("================请求创建第 \(page) 页========================")
        if page >= pageCount || page < 0 || isCreateCells{
            return
        }
        curryCreatedPage = page
        isCreateCells = true
        var columTemp:NSInteger = -1
        for i in 0 ..< self.calculateCountOfCell(inPage: page) {
            if i % self.maxColumnsOfOnePage == 0 {
                columTemp += 1
            }
            self.createViewWithIndex(i: i, withColumn: columTemp, inPage: page,isResize: isResize)
        }
        isCreateCells = false
//        print("================创建第 \(page) 页完成========================")
    }
    
    func calculatePositionWithPage(page:NSInteger, andPosition i:NSInteger, isCycleShow:Bool) -> NSInteger {
        var ii:NSInteger = 0
        if isCycleShow {
            if page + 1 == pageCount {
                ii = i
            } else if page == 0  {
                ii = i + maxCellsOfOnePage * (pageCount - 3)
            } else {
                ii = i + maxCellsOfOnePage * page
            }
        } else {
            if self.isCycleShow {
                if page + 2 ==  pageCount {
                    ii = i
                } else if page + 1 == 0 {
                    ii = i + (pageCount - 3) * maxCellsOfOnePage
                } else {
                    ii = i + maxCellsOfOnePage * page
                }
            } else {
                ii = i + maxCellsOfOnePage * page
            }
        }
        return ii
    }
    
    ///创建cell
    func createViewWithIndex(i:NSInteger, withColumn column:NSInteger, inPage page:NSInteger, isResize:Bool) -> Void {
        if gridViewDataSource == nil {
            return
        }
        let framePosition:NSInteger = self.calculatePositionWithPage(page: page, andPosition: i, isCycleShow: _isCycleShow)
        let dataPosition:NSInteger = self.calculatePositionWithPage(page: _isCycleShow ? page - 1 : page, andPosition: i, isCycleShow: false)
        let cell:CHGGridViewCell = (gridViewDataSource?.cell(forGridView: self, itemAtIndex: _isCycleShow ? dataPosition : framePosition, withData: data?.object(at: _isCycleShow ? dataPosition : framePosition) as AnyObject))!
        cell.frame = self.calculateFrameWithPosition(position: framePosition , andColumn: column, andPage: page)
        cell.tag = _isCycleShow ? dataPosition : framePosition
        cell.addTarget(self, action:#selector(itemTouchUpInside(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(cell)
    }
    
    ///按钮被点击
    func itemTouchUpInside(sender:AnyObject) -> Void {
        let cell:CHGGridViewCell = sender as! CHGGridViewCell
        gridViewDelegate?.gridView(gridView: self, didSelecteAtIndex: sender.tag ,withData: data?.object(at: cell.tag) as AnyObject)
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
        let p:NSInteger = curryCreatedPage % cacheCount
        let cell:CHGGridViewCell = cells.object(at: position % maxCellsOfOnePage + maxCellsOfOnePage * p) as! CHGGridViewCell
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
        let currScrollX:CGFloat = scrollView.contentOffset.x//当前实时坐标
        let pageValueMaxTemp:NSInteger = NSInteger(ceilf(Float(scrollView.contentOffset.x / scrollView.frame.size.width)))///向上取整数  比如1.1 1.6   都会取2
        let pageValueMinTemp:NSInteger = NSInteger(floorf(Float(scrollView.contentOffset.x / scrollView.frame.size.width)))///向下取整  比如1.1  1.6 都会取1
        self.curryPage = lroundf(Float(scrollView.contentOffset.x / scrollView.frame.size.width))//四舍五入   1.1 取1   1.6 取 2
        
        if currScrollX > lastScrollDownX {
            scrollDirection = ScrollDirection.left
            if pageValueMaxTemp > pageValueMax {
                self.createCellsOfPage(page: NSInteger(pageValueMaxTemp), isResize: false)
            }
            if isRebirthRight2LeftStart {
               isRebirthRight2LeftStart = false
                self.createCellsOfPage(page: 1, isResize: false)
            }
            
            if isCycleShow {
                if self.contentOffset.x >= self.frame.width * CGFloat(pageCount - 1) {
                    isRebirthRight2LeftStart = true
                    lastScrollDownX = scrollView.contentOffset.x - (scrollView.frame.width * CGFloat(pageCount - 2)) - 0.0001
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - (scrollView.frame.width * CGFloat(pageCount - 2)), y: 0)
                    ///当轮回创建玩第一页  此处应该创建第2页
                    self.createCellsOfPage(page: curryPage + 1, isResize: false)
                }
            }
        } else if(currScrollX < lastScrollDownX) {
            scrollDirection = ScrollDirection.right
            if pageValueMinTemp < pageValueMin {
                self.createCellsOfPage(page: NSInteger(pageValueMinTemp), isResize: false)
            }
            if isRebirthLeft2RightStart {
                isRebirthLeft2RightStart = false
                self.createCellsOfPage(page: pageCount - 2, isResize: false)
            }
            if isCycleShow {
                if self.contentOffset.x <= 0 {
                    isRebirthLeft2RightStart = true
                    let x:CGFloat = self.contentOffset.x + self.frame.width * CGFloat(pageCount - 2)
                    lastScrollDownX = x + 0.0001
                    scrollView.contentOffset = CGPoint(x: x, y: 0)
                    self.createCellsOfPage(page: curryPage - 1, isResize: false)
                }
            }
        } else {
            //发生轮回
        }
        lastScrollDownX = currScrollX
        pageValueMax = pageValueMaxTemp
        pageValueMin = pageValueMinTemp
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
    }
}
