//
//  CHGTabItem.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/20.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

///此类是TabPage中选项的item类。写此类可以实现不通的风格
class CHGTabItem: UIControl {
    
    var curryItemSelected:Bool = false
    var _curryItemSelected: Bool {
        get {
            return self.curryItemSelected
        }
        set {
            self.curryItemSelected = newValue
        }
    }
    
    ///cell的数据
    var data:AnyObject?
    
    ///此方法会返回当前tabitem需要的数据   如果子类重写此方法 需调用父类的方法，如果不调用则 data不能正确赋值
    func setItemData(data:AnyObject,position:NSInteger) -> Void {
        self.data = data
    }
    
    ///当item被点击后此方法会被调用  selected == true 表示被调用,  此方法中写 item被选中后和选择前的变化
    func setSelected(selected:Bool) -> Void {
        
    }
    
    ///变化率
    func onTabScroll(rateChange:CGFloat) -> Void {
        
    }

    ///创建cell 通过nib名称
    class func initWithNibName(nibName:NSString)->CHGTabItem {
        let nibs =  Bundle.main.loadNibNamed(nibName as String, owner: nil, options: nil)
        return nibs!.last as! CHGTabItem
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}
