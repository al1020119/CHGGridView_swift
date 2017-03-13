//
//  MySlider.swift
//  SwiftTest
//
//  Created by Hogan on 2017/2/22.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class MySlider: CHGSlider {
    
    @IBOutlet var label:UILabel?
    @IBOutlet var imageView:UIImageView?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    ///当页面滑动的时候 会传递 当前滑动进度  以及 左边和右边的按钮
    override func scrollRate(rate:CGFloat,leftItem:CHGTabItem,rightItem:CHGTabItem) -> Void {
        
        label?.text = NSString.localizedStringWithFormat("%.2f", rate) as String
        imageView?.image = UIImage.init(named: "\(Int(rate * 10))")
    }
}
