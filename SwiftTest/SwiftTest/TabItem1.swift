//
//  TabItem1.swift
//  SwiftTest
//
//  Created by 陈 海刚 on 2017/2/21.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class TabItem1: CHGTabItem {

    @IBOutlet var label:UILabel?
    
    
    
    override func setItemData(data: AnyObject,position:NSInteger) {
        super.setItemData(data: data,position: position)
        label?.text = data as? String
    }
    
    override func setCurryItemSelected(curryItemSelected: Bool) {
        label?.textColor = curryItemSelected ? UIColor.red : UIColor.gray
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}
