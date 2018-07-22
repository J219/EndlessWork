//
//  Array+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation

// 这里手动实现了EwkExtesionable，因为Array本身是包含一个范型的，所以无法用另一个范型去包含它

struct EwkExtesionArray<Element> {
    
    public let base: Array<Element>
    
    public init(_ base: Array<Element>) {
        self.base = base
    }
}

extension Array {
    
    var ew: EwkExtesionArray<Element> {
        return EwkExtesionArray<Element>(self)
    }
}

extension EwkExtesionArray {
    
    /// 安全取值
    func element(of index: Int) -> Element? {
        
        guard index >= 0 && index < base.count else {
            return nil
        }
        
        return base[index]
    }
    
    /// 通过下标安全取值
    subscript(index: Int) -> Element? {
        
        return element(of: index)
    }
}
