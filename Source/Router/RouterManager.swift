//
//  RouterManager.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/23.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation
import MGJRouter
import RxSwift

///  全局路由管理器
class RouterManager: NSObject {
    
    /// 重写方法，注册所有路由
    open func registerAllRouter() {
        
        
    }
    
    /// 打开一个页面路由
    ///
    /// - Parameters:
    ///   - page: 路由的URL
    ///   - infoDic: 附加的参数
    ///   - complete: 回调处理，返回一个是否处理的bool值
    func openRouter(page: RouterPageProtocol, infoDic: [String: Any]?, complete: @escaping ((_: RouterCompletionObject) -> Bool)) {
        
        let mgjUrl = MGJRouter.generateURL(withPattern: page.baseUrl, parameters: [page.type])
        self.openRouter(url: mgjUrl ?? "", infoDic: infoDic, complete: complete)
    }
    
    /// 打开一个URL地址路由
    ///
    /// - Parameters:
    ///   - url: 路由的URL字符串
    ///   - infoDic: 附加的参数
    ///   - complete: 回调处理，返回一个是否处理的bool值
    @objc func openRouter(url: String, infoDic: [String: Any]?, complete: @escaping ((_: RouterCompletionObject) -> Bool)) {
        
        var paramDic = infoDic ?? [String: Any]()
        paramDic["routerCompletionBlock"] = complete
        
        DispatchQueue.main.async {
            MGJRouter.openURL(url, withUserInfo: paramDic, completion: nil)
        }
    }
    
}
