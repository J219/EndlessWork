//
//  RouterDefines.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation

/// 定义页面路由的协议
protocol RouterPageProtocol {
    
    /// 该模块的基础地址
    var baseUrl: String { get }
    /// 具体的操作类型
    var type: String { get }
}

extension RouterPageProtocol where Self: RawRepresentable, Self.RawValue == String {
    
    var type: String { return self.rawValue }
}

/// 跳转处理类型
@objc enum RouterJumpType: Int {
    
    /// 不做特殊处理
    case none = 0
    /// 停止下一步操作（例如在网页中停止跳转）
    case block
    /// 在当前导航控制器中Push一个生成好的页面
    case push
    /// 如果当前控制器在导航中，则调用pop方法退回上一级页面
    case pop
    /// 如果当前控制器在导航中，则调用pop方法退回Root页面
    case popToRoot
    /// 退回到某一个指定页面，页面类型取popToControllerType
    case popToController
    /// 通过模态弹出一个生成好的Nav页面或普通页面
    case modal
    /// 调用dismiss，结束一个模态弹出的页面
    case dismiss
    /// 添加一个subview，展示在当前的view上
    case subview
}

/// 路由处理完成的封装
class RouterCompletionObject: NSObject {
    
    /// 跳转类型
    @objc var jumpType = RouterJumpType.none
    /// 控制器，在需要跳转的时候附带
    @objc var controller: UIViewController?
    /// 退回的目标控制器类型，在需要退回的时候附带
    @objc var popToControllerType: AnyClass?
    /// view，添加subview时用
    @objc var view: UIView?
    /// 文字信息，在需要弹Toast时候会附带
    @objc var message: String?
}

