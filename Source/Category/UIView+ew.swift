//
//  UIView+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension EwkExtesion where Base: UIView {
    
    /// 动画key
    var rotateAinimationKey: String { return "wl_animtion_rotate" }
    
    /// 开始旋转动画
    ///
    /// - Parameter duration: 旋转一周的时间，默认1秒
    func startRotate(duration: CFTimeInterval = 1.0) {
        
        guard base.layer.animation(forKey: rotateAinimationKey) == nil else {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = CGFloat.pi * 2.0
        animation.duration = duration
        animation.isCumulative = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        base.layer.add(animation, forKey: rotateAinimationKey)
    }
    
    /// 停止由startRotate方法启动的旋转动画
    func stopRotate() {
        
        guard base.layer.animation(forKey: rotateAinimationKey) != nil else {
            return
        }
        
        base.layer.removeAnimation(forKey: rotateAinimationKey)
    }
    
}

extension Reactive where Base: UIView {
    
    /// Bindable sink for `backgroudColor` property.
    public var backgroudColor: Binder<UIColor?> {
        return Binder(base) { view, color in
            view.backgroundColor = color
        }
    }
    
}
