//
//  CHGSlider.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/21.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

///滑块类,重写此类 可以实现不同的滑块效果
class CHGSlider: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    ///创建cell 通过nib名称
    class func initWithNibName(nibName:NSString)->CHGSlider {
        let nibs =  Bundle.main.loadNibNamed(nibName as String, owner: nil, options: nil)
        return nibs!.last as! CHGSlider
    }
    
    ///当页面滑动的时候 会传递 当前滑动进度  以及 左边和右边的按钮
    func scrollRate(rate:CGFloat,leftItem:CHGTabItem,rightItem:CHGTabItem) -> Void {
        
    }
    
}
