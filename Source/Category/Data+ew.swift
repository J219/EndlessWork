//
//  Data+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation

/// Extend Data with `ew` proxy.
extension Data: EwkExtesionable { }

extension EwkExtesion where Base == Data {
    
    /// 转为json字典
    var jsonDictionary: [String: Any]? {
        
        do {
            return try JSONSerialization.jsonObject(with: base, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    /// 转uft8字符串
    var utf8String: String? {
        return String(data: base, encoding: String.Encoding.utf8)
    }
    
}
