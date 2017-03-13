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
    
    var _curryItemSelected:Bool = false
    var curryItemSelected: Bool {
        get {
            return _curryItemSelected
        }
        set {
            _curryItemSelected = newValue
        }
    }
    
    ///此方法可设置当当前按钮被点击时候的颜色等一些属性等操作
    func setCurryItemSelected(curryItemSelected:Bool) -> Void {
        ///重写此类来设置相信息，比如设置点击按钮前后的颜色
    }
    
    ///cell的数据
    var data:AnyObject?
    
    ///此方法会返回当前tabitem需要的数据   如果子类重写此方法 需调用父类的方法，如果不调用则 data不能正确赋值
    func setItemData(data:AnyObject,position:NSInteger) -> Void {
        self.data = data
    }
    
    
    ///变化率
    func onTabScroll(rateChange:CGFloat) -> Void {
        
    }

    ///创建cell 通过nib名称
    class func initWithNibName(nibName:NSString)->CHGTabItem {
        let nibs =  Bundle.main.loadNibNamed(nibName as String, owner: nil, options: nil)
        return nibs!.last as! CHGTabItem
    }
}
