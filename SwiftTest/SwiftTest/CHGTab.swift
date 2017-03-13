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
    func tabSlider(tab:CHGTab) -> CHGSlider
    ///获取tab的宽度 tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth 有用
    func tabScrollWidth(tab:CHGTab,withPosition position:NSInteger,withData data:AnyObject) -> CGFloat
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
    var sliderC:CHGSlider?
    
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
    ///是否已经布局
    var isLayoutSubView:Bool = false
    
    var itemTemp:NSMutableArray = NSMutableArray()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    ///初始化数据
    func initView(isResize:Bool) -> Void {
        if data == nil || data?.count == 0 {
            return;
        }
        itemTemp.removeAllObjects()
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
                if i == currySelectedPosition {
                    self.currySelectedTabItem = cell;
                }
                cell.setCurryItemSelected(curryItemSelected: i == currySelectedPosition)
                self.addSubview(cell)
                itemTemp.add(cell)
                if tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth {
                    self.contentSize = CGSize(width: self.contentSize.width + spacing + cell.frame.size.width, height: 1)
                }
            }
            self.contentSize = CGSize(width: self.contentSize.width + spacing, height: 1)
        }
        
        if  tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth {
            let width = tabDataSource?.tabSliderHeight(tab: self)
            slider?.frame = CGRect(x: 0, y: sliderLocation == CHGSliderLocation.Down ? self.frame.height - sliderHeight : 0, width: width!, height: sliderHeight)
        } else {
//            let item0Frame = self.calculateRect(position: currySelectedPosition)
            let item0Frame:CGRect = (itemTemp.object(at: 0) as! CHGTabItem).frame
            //滑块1
            slider?.frame = CGRect(x: item0Frame.origin.x, y: sliderLocation == CHGSliderLocation.Down ? self.frame.height - sliderHeight : 0, width: item0Frame.width, height: sliderHeight)
            //滑块2
            sliderC?.frame = CGRect(x: -((slider?.frame.size.width)! + spacing), y: sliderLocation == CHGSliderLocation.Down ? self.frame.height - sliderHeight : 0, width: item0Frame.width, height: sliderHeight)
            
            sliderC?.isHidden = !isCycleShow
        }
        sliderC?.isHidden = tabItemLayoutMode == CHGTabItemLayoutMode.AutoWidth
    }
    
    func relaodData() -> Void {
        self.initView(isResize: false)
        selectItemWithPosition(position: currySelectedPosition,fromReload: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLayoutSubView {
            isLayoutSubView = true
            self.showsVerticalScrollIndicator = false
            self.showsHorizontalScrollIndicator = false
            self.delegate = self
            
            self.removeSubviews()
            self.slider = tabDataSource?.tabSlider(tab:self)
            self.sliderC = tabDataSource?.tabSlider(tab:self)
            self.addSubview(slider!)
            self.addSubview(sliderC!)
            self.initView(isResize: false)
        }
    }
    
    func itemTap(sender:AnyObject) -> Void {
        let view:UIView = sender as! UIView
        tabDelegate?.tabItemTap(position:view.tag)
    }

    
    ///计算frame
    func calculateRect(position:NSInteger) -> CGRect {
        var rect:CGRect!
        if tabItemLayoutMode == CHGTabItemLayoutMode.AverageWidth {
            let itemWidth = (self.frame.width - spacing * CGFloat((data?.count)! + 1)) / CGFloat((data?.count)!)
            let x = CGFloat(position) * (itemWidth + spacing) + spacing
            rect = CGRect(x: x, y: sliderLocation == CHGSliderLocation.Down ? 0 : sliderHeight, width: itemWidth, height: self.frame.height - sliderHeight)
        } else {
            let width:CGFloat = (tabDataSource?.tabScrollWidth(tab: self, withPosition: position,withData: data?.object(at: position) as AnyObject))!
            rect = CGRect(x: self.contentSize.width + spacing, y: sliderLocation == CHGSliderLocation.Down ? 0 : sliderHeight, width: width, height: self.frame.height - sliderHeight)
            scrollTabItemRects.setValue(rect, forKey: String(position))
        }
        return rect
    }

    ///设置当前选择的位置
    func selectItemWithPosition(position:NSInteger,fromReload:Bool) -> Void {
        let view1:UIView? = self.findView(ByTag: position + 1, withClassType: CHGTabItem.classForCoder())
        if view1 != nil {
            let currySelectItem:CHGTabItem = view1 as! CHGTabItem
            currySelectedTabItem?.setCurryItemSelected(curryItemSelected: false)
            currySelectItem.setCurryItemSelected(curryItemSelected: true)
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
    
    ///滑动中
    func gridViewDidScroll(_ gridView: CHGGridView) {
        let rateTemp:CGFloat = gridView.contentOffset.x / gridView.frame.width
        let minValue = floorf(Float(rateTemp))
        let maxValue = ceilf(Float(rateTemp))
        var curryPage = lroundf(Float(rateTemp))
        curryPage = gridView.isCycleShow ? curryPage - 1 : curryPage
        self.selectItemWithPosition(position: curryPage, fromReload: false)
        if tabItemLayoutMode ==  CHGTabItemLayoutMode.AutoWidth {
            if (Int(maxValue) > (data?.count)! || minValue < 0) || (isCycleShow && minValue == 0) || (!isCycleShow && Int(maxValue) == (data?.count)!) {
                return
            }
            let startView:CHGTabItem = itemTemp.object(at: isCycleShow ? Int(minValue) - 1 : Int(minValue)) as! CHGTabItem
            let endView:CHGTabItem = itemTemp.object(at: isCycleShow ? Int(maxValue) - 1 : Int(maxValue)) as! CHGTabItem
            let starX:CGFloat = startView.frame.origin.x
            let endX:CGFloat = endView.frame.origin.x
            
            let x:CGFloat = startView.frame.origin.x + (rateTemp - CGFloat(minValue)) * (endX - starX)
            let w:CGFloat = startView.frame.width + (endView.frame.size.width - startView.frame.size.width) * (rateTemp - CGFloat(minValue))
            slider?.frame = CGRect(x: x,
                                   y: (slider?.frame.origin.y)!,
                                   width: w,
                                   height: sliderHeight)
            slider?.scrollRate(rate: rateTemp - CGFloat(minValue), leftItem: startView, rightItem: endView)
        } else {
            if isCycleShow {
                let array:NSArray = self.calculateSliderRectWithGridView(gridView: gridView)
                slider?.frame = CGRect(x: array.object(at: 0) as! CGFloat,
                                       y: (slider?.frame.origin.y)!,
                                       width: (slider?.frame.width)!,
                                       height: (slider?.frame.height)!)
                sliderC?.frame = CGRect(x: array.object(at: 1) as! CGFloat,
                                        y: (sliderC?.frame.origin.y)!,
                                        width: (sliderC?.frame.width)!,
                                        height: (sliderC?.frame.height)!)
            } else {
                let x:CGFloat = rateTemp * ((slider?.frame.width)! + spacing) + spacing
                slider?.frame = CGRect(x: x,
                                       y: (slider?.frame.origin.y)!,
                                       width: (slider?.frame.width)!,
                                       height: (slider?.frame.height)!)
            }
            
            if Int(maxValue) > (data?.count)! || minValue <= 0 {
                return
            }
            let startView:CHGTabItem = itemTemp.object(at: Int(minValue) - 1) as! CHGTabItem
            let endView:CHGTabItem = itemTemp.object(at: Int(maxValue) - 1) as! CHGTabItem
            slider?.scrollRate(rate: rateTemp - CGFloat(minValue), leftItem: startView, rightItem: endView)
            sliderC?.scrollRate(rate: rateTemp - CGFloat(minValue), leftItem: startView, rightItem: endView)
            
        }
    }
    
    func calculateSliderRectWithGridView(gridView:CHGGridView) -> NSArray {
        let rateTemp:CGFloat = gridView.contentOffset.x / gridView.frame.size.width
        
        let x:CGFloat = (rateTemp - 1) * ((slider?.frame.size.width)! + spacing) + spacing
        var xCopy:CGFloat = 0
        
        if gridView.contentOffset.x < gridView.frame.size.width {
            xCopy = ((slider?.frame.size.width)! + spacing) * CGFloat(gridView.pageCount - 2) + x
        } else {
            xCopy = -((slider?.frame.size.width)! + spacing)
        }
        
        if gridView.contentOffset.x > gridView.frame.size.width * CGFloat(gridView.pageCount - 2) {
            xCopy = x - CGFloat(gridView.pageCount - 2) * ((slider?.frame.size.width)! + spacing)
        }
        
        return [x,xCopy]
        
    }
    
    func gridViewDidEndScrollingAnimation(_ gridView: CHGGridView){

    }
    
    ///scrollView 停止滑动
    func scrollViewDidStop(gridView:CHGGridView) -> Void {
        
    }
    
    
    ///以下是当前UIScrollView的滑动监听-------------------------------------------------------------------------------------------------------------------
    ///手指开始拖动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }
    
    ///手指结束拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    ///已经结束减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }
    
    ///滑动中
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    ///通过外部触发scrollview滑动后停止的回掉
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
}
