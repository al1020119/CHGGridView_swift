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
    
    var columns = 1
    var rows = 2
    var lineWidth = 1
    var aroundLine:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        gridView?.gridViewDataSource = self;
        gridView?.data = self.simaluData()//["1","2","3","4","5","6","7","8","9","10","11","12","13"]
        gridView?.registerNibName(nibName: "MyCHGGridViewCell", forCellReuseIdentifier: "MyCHGGridViewCell")
        gridView?.registerNibName(nibName: "MyCHGGridViewCell2", forCellReuseIdentifier: "MyCHGGridViewCell2")
        gridView?.intervalOfCell = CGFloat(lineWidth)
        gridView?.roundLineShow = aroundLine
        gridView?.isCycleShow = false
    }
    
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
    
    //减少
    @IBAction func jian(sender:AnyObject)->Void{
        columns -= 1
        rows -= 1
        columns = columns <= 0 ? 1: columns
        rows = rows <= 0 ? 1:rows
        gridView?.data = simaluData()
        gridView?.reloadData()
    }
    
    //增加
    @IBAction func jia(sender:AnyObject)->Void{
        columns += 1
        rows += 1
        gridView?.data = simaluData()
        gridView?.reloadData()
    }
    
    //下一页
    @IBAction func nextPage(sender:AnyObject)->Void{
        gridView?.scroll2Page(page: (gridView?.curryPage)! + 1,animated: true)
    }
    
    //上一页
    @IBAction func previousPage(sender:AnyObject)->Void{
        gridView?.scroll2Page(page:(gridView?.curryPage)! - 1,animated: true)
    }
    
    //添加周围线条
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
    
    ///按页显示
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
    
    ///定时开关
    @IBAction func timerShow(sender:AnyObject)->Void {
        gridView?.isTimerShow = !(gridView?.isTimerShow)!
        gridView?.reloadData()
    }
    
    ///循环显示
    @IBAction func cycleShow(sender:AnyObject)->Void {
        gridView?.isCycleShow = !(gridView?.isCycleShow)!
        gridView?.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
}
