//
//  BaseSectionView.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/23.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation

import RxSwift

// MARK: - 通用协议

/// section view model的协议
protocol SectionViewModelProtocol {
    
    /// cell view model 数组
    var cellViewModels: [TableViewCellViewModelProtocol] { get set }
    
    /// 主动刷新Section
    var callReloadSection: (() -> Void)? { get set }
}

/// section view（header或footer）的协议
protocol SectionViewCompatible {
    
    /// 返回一个新建实例
    static func createInstance(with viewModel: SectionViewModelProtocol) -> UITableViewHeaderFooterView?
    
    /// 返回重用ID
    static func reuseID(with viewModel: SectionViewModelProtocol) -> String
    
    /// 计算高度
    static func height(with viewModel: SectionViewModelProtocol, tableSize: CGSize) -> CGFloat
    
    /// 通过view model更新view
    func updateView(with viewModel: SectionViewModelProtocol)
}

// MARK: - 基于通用协议的MVVM基类

/// Section View Model的MVVM基类
class BaseSectionViewModel: NSObject, SectionViewModelProtocol {
    
    /// 监听关系回收袋
    var disposeBag = DisposeBag()
    
    /// cell view model 数组
    var cellViewModels = [TableViewCellViewModelProtocol]()
    
    /// 刷新section回调
    var callReloadSection: (() -> Void)?
    
    /// 触发刷新的事件
    let reload = PublishSubject<Void>()
    
    override init() {
        super.init()
        reload.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                self?.callReloadSection?()
            })
            .disposed(by: disposeBag)
    }
}

/// Section View的MVVM基类
class BaseSectionView: UITableViewHeaderFooterView, SectionViewCompatible {
    
    /// 监听关系回收袋
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    /// 便捷初始化方法，加载一个xib，放在contentview里
    ///
    /// - Parameters:
    ///   - xibName: xib 名
    ///   - objectIndex: 需要加载的view的index
    convenience init(xibName: String, reuseIdentifier: String?, objectIndex: Int = 0) {
        self.init(reuseIdentifier: reuseIdentifier)
        
        if let aView = UINib(nibName: xibName, bundle: nil).instantiate(withOwner: self, options: nil).ew.element(of: objectIndex) as? UIView {
            
            aView.frame = contentView.bounds
            aView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(aView)
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SectionViewCompatible
    
    class func createInstance(with viewModel: SectionViewModelProtocol) -> UITableViewHeaderFooterView? {
        return BaseSectionView(reuseIdentifier: BaseSectionView.reuseID(with: viewModel))
    }
    
    class func reuseID(with viewModel: SectionViewModelProtocol) -> String {
        return "BaseSectionView"
    }
    
    /// 计算高度
    class func height(with viewModel: SectionViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 10
    }
    
    /// 通过view model更新view，子类重写时需要调用super方法
    func updateView(with viewModel: SectionViewModelProtocol) {
        disposeBag = DisposeBag()
    }
    
}
