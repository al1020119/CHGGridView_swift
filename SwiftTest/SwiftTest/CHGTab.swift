//
//  CHGTab.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/20.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

///CHGTabItem item展示方式
enum CHGTabItemLayoutMode {
    case AverageWidth   ///平均宽度
    case AutoWidth      ///自动宽度（自定义宽度）
}

///滑块位置
enum CHGSliderLocation {
    case Top        //表示滑块在item的顶部
    case Down       //表示滑块在item的底部
}

protocol CHGTabDataSource {
    ///返回TabItem
    func tab(tab:CHGTab,itemAtIndex position:NSInteger,withData data:AnyObject) -> CHGTabItem
    ///滑块的高度
    func tabSliderHeight(tab:CHGTab) -> CGFloat
    ///返回滑块
    func tabSlider() -> CHGSlider
    ///获取tab的宽度 tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth 有用
    func tabScrollWidth(tab:CHGTab,withPosition position:NSInteger) -> CGFloat
}

///CHGTabDelegate
protocol CHGTabDelegate {
    ///item被点击
    func tabItemTap(position:NSInteger) -> Void
}

class CHGTab: UIScrollView ,CHGGridViewScrollDelegate,UIScrollViewDelegate{

    ///tabItem显示方式
    var tabItemLayoutMode:CHGTabItemLayoutMode = CHGTabItemLayoutMode.AverageWidth
    
    var data:NSArray?
    ///item之间的间隔
    var spacing:CGFloat = 0
    ///CHGTabDataSource
    var tabDataSource:CHGTabDataSource?
    ///滑块
    var slider:CHGSlider?
    ///滑块位置
    var sliderLocation:CHGSliderLocation = CHGSliderLocation.Down
    ///滑块高度
    var sliderHeight:CGFloat = 0
    
    var currySelectedTabItem:CHGTabItem?
    
    var currySelectedPosition:NSInteger = 0
    ///item被点击的回掉
    var tabDelegate:CHGTabDelegate?
    ///可以滑动的TabItem的Rect
    var scrollTabItemRects:NSMutableDictionary = NSMutableDictionary()
    ///是否循环现实
    var isCycleShow:Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.showsHorizontalScrollIndicator = false;
        self.showsVerticalScrollIndicator = false;
        self.delegate = self
        
        self.slider = tabDataSource?.tabSlider()
        self.addSubview(slider!)
        
        self.initView(isResize: false)
    }
    
    ///初始化数据
    func initView(isResize:Bool) -> Void {
        self.sliderHeight = (tabDataSource?.tabSliderHeight(tab: self))!
        if !isResize {
            for v in self.subviews {
                if v is CHGTabItem {
                    v.removeFromSuperview()
                }
            }
            self.contentSize = CGSize(width: 0, height: 0)
            for i in 0 ..< (data?.count)! {
                let cell:CHGTabItem = (tabDataSource?.tab(tab: self, itemAtIndex: i, withData: data?.object(at: i) as AnyObject))!
                cell.frame = self.calculateRect(position: i)
                cell.tag = i + 1
                cell.addTarget(self, action: #selector(itemTap(sender:)), for: UIControlEvents.touchUpInside)
                cell.setItemData(data: data?.object(at: i) as AnyObject,position: i)
                cell.curryItemSelected = i == 0 //如果是第一个 默认为选中状态
                self.addSubview(cell)
                if tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth {
                    self.contentSize = CGSize(width: self.contentSize.width + spacing + cell.frame.size.width, height: 1)
                }
            }
            self.contentSize = CGSize(width: self.contentSize.width + spacing, height: 1)
        }
        
        if  tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth {
            
        } else {
            let item0Frame = self.calculateRect(position: currySelectedPosition)
            slider?.frame = CGRect(x: item0Frame.origin.x, y: sliderLocation == CHGSliderLocation.Down ? self.frame.height - sliderHeight : 0, width: item0Frame.width, height: sliderHeight)
        }
        slider?.isHidden = tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth
    }
    
    func relaodData() -> Void {
        self.initView(isResize: false)
        selectItemWithPosition(position: currySelectedPosition,fromReload: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            self.initView(isResize: true)
            selectItemWithPosition(position: currySelectedPosition,fromReload: false)
        }
    }
    
    func itemTap(sender:AnyObject) -> Void {
        let view:UIView = sender as! UIView
        tabDelegate?.tabItemTap(position: isCycleShow ? view.tag + 1 : view.tag)
    }
    
    
    
    func modfIfCarryMax(f:CGFloat) -> CGFloat {
        let ff:CGFloat =  f == 0 ? 0.00001 : f
        let a = modf(ff)
        return a.1 == 0 ? 1.0 : a.1
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "curryPage" {

        }
    }
    
    ///计算frame
    func calculateRect(position:NSInteger) -> CGRect {
        var rect:CGRect!
        if tabItemLayoutMode == CHGTabItemLayoutMode.AverageWidth {
            let itemWidth = (self.frame.width - spacing * CGFloat((data?.count)! + 1)) / CGFloat((data?.count)!)
            let x = CGFloat(position) * (itemWidth + spacing) + spacing
            rect = CGRect(x: x, y: sliderLocation == CHGSliderLocation.Down ? 0 : sliderHeight, width: itemWidth, height: self.frame.height - sliderHeight)
        } else {
            let width:CGFloat = (tabDataSource?.tabScrollWidth(tab: self, withPosition: position))!
            rect = CGRect(x: self.contentSize.width + spacing, y: sliderLocation == CHGSliderLocation.Down ? 0 : sliderHeight, width: width, height: self.frame.height - sliderHeight)
            scrollTabItemRects.setValue(rect, forKey: String(position))
        }
        return rect
    }

    ///设置当前选择的位置
    func selectItemWithPosition(position:NSInteger,fromReload:Bool) -> Void {
        if position < 0 || position >= (data?.count)! || currySelectedPosition == position {
            if fromReload {
                let view1:UIView? = self.findView(ByTag: position + 1, withClassType: CHGTabItem.classForCoder())
                if view1 != nil {
                    let currySelectItem:CHGTabItem = view1 as! CHGTabItem
                    currySelectItem.setSelected(selected: true)
                    let rect:CGRect = CGRect(x: currySelectItem.center.x - self.frame.width / 2, y: 0, width: self.frame.width, height: self.frame.height)
                    self.scrollRectToVisible(rect, animated: true)
                    currySelectedTabItem = currySelectItem
                    currySelectedPosition = position
                }
            }
            return
        }
        print("curryPage = \(position)")
        
        let view1:UIView? = self.findView(ByTag: position + 1, withClassType: CHGTabItem.classForCoder())
        print("view1 = \(view1)")
        if view1 != nil {
            let currySelectItem:CHGTabItem = view1 as! CHGTabItem
            currySelectItem.setSelected(selected: true)
            currySelectedTabItem?.setSelected(selected: false)
            let rect:CGRect = CGRect(x: currySelectItem.center.x - self.frame.width / 2, y: 0, width: self.frame.width, height: self.frame.height)
            self.scrollRectToVisible(rect, animated: true)
            currySelectedTabItem = currySelectItem
            currySelectedPosition = position
        }
    }
    
    ///手指开始拖动
    func gridViewWillBeginDragging(_ gridView: CHGGridView) {

    }
    
    ///手指结束拖动
    func gridViewDidEndDragging(_ gridView: CHGGridView, willDecelerate decelerate: Bool) {
        
    }
    
    ///已经结束减速
    func gridViewDidEndDecelerating(_ gridView: CHGGridView) {
        
    }
    
    ///计算滑动的百分比
    func calculatePercent(ratio:CGFloat,scrollDirection:ScrollDirection) -> CGFloat {
        if scrollDirection == ScrollDirection.left {
            return self.modfIfCarryMax(f: ratio)
        } else if scrollDirection == ScrollDirection.right {
            return (1 - (1 - self.modfIfCarryMax(f:ratio) == 1 ? 0 : self.modfIfCarryMax(f:ratio)))
        }
        return 0
    }
    
    
    ///滑动中
    func gridViewDidScroll(_ gridView: CHGGridView) {
        var curryPage = lroundf(Float(gridView.contentOffset.x / gridView.frame.size.width))
        curryPage = (gridView.isCycleShow) ? curryPage - 1 : curryPage
        
        if tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth {
            selectItemWithPosition(position: curryPage,fromReload: false)
        } else {
            let view:UIView = self.findView(ByTag: 1, withClassType: CHGTabItem.classForCoder())!
//            let offsetX:CGFloat = (gridView.isCycleShow ? (gridView.contentOffset.x - spacing * CGFloat(curryPage)) / CGFloat((data?.count)!) : (gridView.contentOffset.x - spacing * CGFloat(curryPage)) / CGFloat((data?.count)!))
            
            let offsetX = (gridView.contentOffset.x - spacing * CGFloat(curryPage)) / CGFloat((data?.count)!)
            slider?.frame.origin = CGPoint(x: offsetX + spacing - (gridView.isCycleShow ? view.frame.width + spacing: 0), y: (slider?.frame.origin.y)!)
            selectItemWithPosition(position: curryPage, fromReload: false)
        }
    }
    
    func gridViewDidEndScrollingAnimation(_ gridView: CHGGridView){

    }
    
    ///scrollView 停止滑动
    func scrollViewDidStop(gridView:CHGGridView) -> Void {
        
    }
    
    
    
    
    ///以下是当前UIScrollView的滑动监听-------------------------------------------------------------------------------------------------------------------
    ///手指开始拖动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        isStopScroll = false
    }
    
    ///手指结束拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    ///已经结束减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        isStopScroll = true
    }
    
    ///滑动中
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        isStopScroll = false
    }
    ///通过外部触发scrollview滑动后停止的回掉
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        isStopScroll = true
        
    }
}
