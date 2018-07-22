//
//  UIColor+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation
import UIKit

extension EwkExtesion where Base: UIColor {
    
    /// 颜色转为UIImage
    ///
    /// - Returns: 生成的UIImage
    func toImage() -> UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(base.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
