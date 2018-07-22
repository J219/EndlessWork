//
//  Int+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation

/// Extend Int with `ew` proxy.
extension Int: EwkExtesionable { }

extension EwkExtesion where Base == Int {
    
    /// 转为NSNumber对象
    var number: NSNumber {
        return NSNumber(value: base)
    }
    
}
