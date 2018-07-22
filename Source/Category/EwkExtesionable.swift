//
//  EwkExtesionable.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation

public struct EwkExtesion<Base>: TypeExtesionable {
    /// Base object to extend.
    public let base: Base
    
    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol TypeExtesionable {
    associatedtype Base
    var base: Base { get }
    init(_ base: Base)
}

/// A type that has Ewk extensions.
public protocol EwkExtesionable {
    /// Extended type
    associatedtype CompatibleType
    
    /// Ewk extensions.
    static var ew: EwkExtesion<CompatibleType>.Type { get set }
    
    /// Ewk extensions.
    var ew: EwkExtesion<CompatibleType> { get set }
}

extension EwkExtesionable {
    /// Ewk extensions.
    public static var ew: EwkExtesion<Self>.Type {
        get {
            return EwkExtesion<Self>.self
        }
        set {
            // this enables using Ewk to "mutate" base type
        }
    }
    
    /// Ewk extensions.
    public var ew: EwkExtesion<Self> {
        get {
            return EwkExtesion(self)
        }
        set {
            // this enables using Ewk to "mutate" base object
        }
    }
}

import class Foundation.NSObject

/// Extend NSObject with `Ewk` proxy.
extension NSObject: EwkExtesionable { }
