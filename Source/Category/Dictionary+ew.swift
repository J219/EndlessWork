//
//  Dictionary+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation

// 这里手动实现了EwkExtesionable，因为Dictionary本身是包含一个范型的，所以无法用另一个范型去包含它

struct EwkExtesionDictionary<Key: Hashable, Value> {
    
    public let base: Dictionary<Key, Value>
    
    public init(_ base: Dictionary<Key, Value>) {
        self.base = base
    }
}

extension Dictionary {
    
    var ew: EwkExtesionDictionary<Key, Value> {
        return EwkExtesionDictionary<Key, Value>(self)
    }
}


extension EwkExtesionDictionary {
    
    /// 转json数据
    var jsonData: Data? {
        
        do {
            return try JSONSerialization.data(withJSONObject: base, options: [])
        } catch {
            return nil
        }
    }
    
    /// 转json字符串
    var jsonString: String? {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: base, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
