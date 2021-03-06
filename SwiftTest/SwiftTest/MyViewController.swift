//
//  MyViewController.swift
//  SwiftTest
//
//  Created by Hogan on 2017/2/17.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class MyViewController: UIViewController ,CHGGridViewDataSource{
    
    @IBOutlet var gridView:CHGGridView?
    
    var columns = 2
    var rows = 2
    var lineWidth = 1
    var aroundLine:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        gridView?.gridViewDataSource = self;
        gridView?.data = self.simaluData()
        gridView?.registerNibName(nibName: "MyCHGGridViewCell", forCellReuseIdentifier: "MyCHGGridViewCell")
//        gridView?.registerNibName(nibName: "MyCHGGridViewCell2", forCellReuseIdentifier: "MyCHGGridViewCell2")
        gridView?.intervalOfCell = CGFloat(lineWidth)
        gridView?.roundLineShow = aroundLine
        gridView?.isCycleShow = false
    }
    
    ///构造模拟数据
    func simaluData() -> NSArray {
        let data:NSMutableArray = NSMutableArray()
        for i in 0 ..< columns * rows * 4{
            data[i] = i
        }
        data.add("测试")
        return data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //减少一行 一列
    @IBAction func jian(sender:AnyObject)->Void{
        columns -= 1
        rows -= 1
        columns = columns <= 0 ? 1: columns
        rows = rows <= 0 ? 1:rows
        gridView?.data = simaluData()
        gridView?.reloadData()
    }
    
    //增加一行 一列
    @IBAction func jia(sender:AnyObject)->Void{
        columns += 1
        rows += 1
        gridView?.data = simaluData()
        gridView?.reloadData()
    }
    
    //展示下一页
    @IBAction func nextPage(sender:AnyObject)->Void{
        gridView?.scroll2Page(page: (gridView?.curryPage)! + 1,animated: true)
    }
    
    //展示上一页
    @IBAction func previousPage(sender:AnyObject)->Void{
        gridView?.scroll2Page(page:(gridView?.curryPage)! - 1,animated: true)
    }
    
    //显示／关闭周围线条
    @IBAction func aroundLine(sender:AnyObject)->Void {
        aroundLine = !aroundLine
        gridView?.roundLineShow = aroundLine
        gridView?.reloadData()
    }
    
    ///减少线条的粗细
    @IBAction func lineJian(sender:AnyObject)->Void {
        lineWidth -= 1
        if lineWidth < 0 {
            lineWidth = 0
        }
        gridView?.intervalOfCell = CGFloat(lineWidth)
        gridView?.reloadData()
    }
    
    ///减少线条的粗细
    @IBAction func lineJia(sender:AnyObject)->Void {
        lineWidth += 1
        gridView?.intervalOfCell = CGFloat(lineWidth)
        gridView?.reloadData()
    }
    
    ///按页／关闭按页显示
    @IBAction func showWithPage(sender:AnyObject)->Void {
        gridView?.isPagingEnabled = !(gridView?.isPagingEnabled)!
        gridView?.scroll2Page(page: (gridView?.curryPage)!, animated: true)
        gridView?.reloadData()
    }
    
    ///减少线条的粗细
    @IBAction func showPageDiver(sender:AnyObject)->Void {
        gridView?.isShowPageDivider = !(gridView?.isShowPageDivider)!
        gridView?.reloadData()
    }
    
    ///定时显示 开／关
    @IBAction func timerShow(sender:AnyObject)->Void {
        gridView?.isTimerShow = !(gridView?.isTimerShow)!
        gridView?.reloadData()
    }
    
    ///循环显示 开／关
    @IBAction func cycleShow(sender:AnyObject)->Void {
        gridView?.isCycleShow = !(gridView?.isCycleShow)!
        gridView?.reloadData()
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
        let cell:MyCHGGridViewCell = (gridView as! CHGGridView).dequeueReusableCellWithIdentifier(identifier: "MyCHGGridViewCell", withPosition: position) as! MyCHGGridViewCell
    cell.backgroundColor = position % 2 == 0 ? UIColor.blue : UIColor.yellow
        cell.label?.text = String(describing: data)
        return cell
    }
}
