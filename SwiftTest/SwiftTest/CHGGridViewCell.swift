//
//  CHGGridViewCell.swift
//  SwiftTest
//
//  Created by Hogan on 2017/2/17.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

///CHGGridViewCell类  类似UITableViewCell类
class CHGGridViewCell: UIControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    ///创建cell 通过nib名称
    class func initWithNibName(nibName:NSString)->CHGGridViewCell {
        let nibs =  Bundle.main.loadNibNamed(nibName as String, owner: nil, options: nil)
        return nibs!.last as! CHGGridViewCell
    }
    

}
