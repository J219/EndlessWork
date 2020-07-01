//
//  UIImage+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation
import UIKit

extension EwkExtesion where Base: UIImage {
    
    /// 缩放图片
    ///
    /// - Parameter scaleSize: 目标尺寸
    /// - Returns: 返回缩放后的图片
    func scaled(by scaleSize: CGSize) -> UIImage? {
        
        guard scaleSize.width > 0 && scaleSize.height > 0 else {
            return nil
        }
        
        //开启图形上下文
        UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
        //绘制图片
        base.draw(in: CGRect(x: 0, y: 0, width: scaleSize.width, height: scaleSize.height))
        //从图形上下文获取图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭图形上下文
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
}
