//
//  String+ew.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation
import UIKit

/// Extend String with `ew` proxy.
extension String: EwkExtesionable { }

extension EwkExtesion where Base == String {
    
    /// base 64 转码
    func base64String() -> String? {
        
        return base.data(using: .utf8)?.base64EncodedString()
    }
    
    /// 加密的手机号，例如133****1234
    func securityPhone() -> String {
        return replace(from: 3, to: 7, with: "****")
    }
    
    /// 转换为通知名
    var notificationName: Notification.Name {
        return Notification.Name(rawValue: base)
    }
    
    /// 转换为json字典
    var jsonDictionary: [String: Any]? {
        
        guard let data = base.data(using: String.Encoding.utf8) else {
            return nil
        }
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    /// 转int值，可空
    var int: Int? {
        return Int(base)
    }
    
    /// 转int值，默认0
    var intValue: Int {
        return int ?? 0
    }
    
    /// 截取字符串，超过边界时返nil
    ///
    /// - Parameters:
    ///   - startInt: 开始位置
    ///   - endInt: 结束位置（不包含该位置）
    /// - Returns: 截取的字符串
    func substring(from startInt: Int, to endInt: Int) -> String? {
        
        guard startInt >= 0 && startInt < base.count else {
            return nil
        }
        guard endInt > 0 && endInt <= base.count else {
            return nil
        }
        guard startInt < endInt else {
            return nil
        }
        
        let startIndex = base.index(base.startIndex, offsetBy: startInt)
        let endIndex = base.index(base.startIndex, offsetBy: endInt)
        return String(base[startIndex..<endIndex])
        
    }
    
    /// 截取字符串，不会超过边界
    ///
    /// - Parameters:
    ///   - startInt: 开始位置
    ///   - endInt: 结束位置（不包含该位置）
    /// - Returns: 截取的字符串
    func substringValue(from startInt: Int, to endInt: Int) -> String {
        
        var startIntValue = startInt
        var endIntValue = endInt
        
        guard startIntValue < base.count else {
            return ""
        }
        guard endIntValue > 0  else {
            return ""
        }
        guard startIntValue < endIntValue else {
            return ""
        }
        
        
        if startInt < 0 {
            startIntValue = 0
        } else if startInt >= base.count {
            startIntValue = base.count - 1
        }
        
        if endInt < 0 {
            endIntValue = 0
        } else if endInt > base.count {
            endIntValue = base.count
        }
        
        //        if endIntValue <= startIntValue {
        //            endIntValue = startIntValue + 1
        //        }
        
        let startIndex = base.index(base.startIndex, offsetBy: startIntValue)
        let endIndex = base.index(base.startIndex, offsetBy: endIntValue)
        return String(base[startIndex..<endIndex])
    }
    
    /// 替换字符串，不会超过边界
    ///
    /// - Parameters:
    ///   - startInt: 开始位置
    ///   - endInt: 结束位置（不包含该位置）
    ///   - string: 用来替换的字符串
    /// - Returns: 处理完的字符串
    func replace(from startInt: Int, to endInt: Int, with string: String) -> String {
        var startIntValue = startInt
        var endIntValue = endInt
        
        guard startIntValue < base.count else {
            return ""
        }
        guard endIntValue > 0  else {
            return ""
        }
        guard startIntValue < endIntValue else {
            return ""
        }
        
        
        if startInt < 0 {
            startIntValue = 0
        } else if startInt >= base.count {
            startIntValue = base.count - 1
        }
        
        if endInt < 0 {
            endIntValue = 0
        } else if endInt > base.count {
            endIntValue = base.count
        }
        
        
        let startIndex = base.index(base.startIndex, offsetBy: startIntValue)
        let endIndex = base.index(base.startIndex, offsetBy: endIntValue)
        
        return base.replacingCharacters(in: startIndex..<endIndex, with: string)
    }
    
    
    /// 返回一个子字符串的NSRange
    ///
    /// - Parameter subStr: 子字符串
    /// - Returns: NSRange类型的结果，可空
    func range(of subStr: String) -> NSRange? {
        
        guard let range = base.range(of: subStr) else {
            return nil
        }
        
        let location = base.distance(from: base.startIndex, to: range.lowerBound)
        let length = base.distance(from: range.lowerBound, to: range.upperBound)
        
        return NSMakeRange(location, length)
    }
    
    
    /// 计算字符串完整size
    ///
    /// - Parameters:
    ///   - font: 字体
    ///   - limitWidth: 最大宽度
    /// - Returns: 字符串显示的size
    func size(withFont font: UIFont, limitWidth: CGFloat) -> CGSize {
        
        let normalText: NSString = base as NSString
        let size = CGSize(width: limitWidth, height: CGFloat.greatestFiniteMagnitude)
        
        return normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).size
    }
    
    
    
    
    
    
}
