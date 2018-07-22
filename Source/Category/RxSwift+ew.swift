//
//  RxSwift+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType where E == String? {
    
    /// 跳过空值返回一个非可选值
    func skipNil() -> Observable<String> {
        return filter { $0 != nil }
            .map { $0! }
    }
    
}

extension ObservableType where E == Int? {
    
    /// 跳过空值返回一个非可选值
    func skipNil() -> Observable<Int> {
        return filter { $0 != nil }
            .map { $0! }
    }
    
}

extension ObservableType where E == Bool? {
    
    /// 跳过空值返回一个非可选值
    func skipNil() -> Observable<Bool> {
        return filter { $0 != nil }
            .map { $0! }
    }
    
}
