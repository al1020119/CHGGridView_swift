//
//  CHGBase.swift
//  SwiftTest
//
//  Created by Hogan on 2017/2/21.
//  Copyright © 2017年 Hogan. All rights reserved.
//


import UIKit

extension UIView {
    
    ///通过tag 在view中寻找view
    func findView(ByTag tag:NSInteger, withClassType classType:AnyClass) -> UIView? {
        for item in self.subviews {
            if item.tag == tag && item.isKind(of: classType) {
                return item
            }
        }
        return nil
    }
    
}
