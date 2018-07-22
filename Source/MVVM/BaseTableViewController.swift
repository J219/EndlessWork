//
//  BaseTableViewController.swift
//  EndlessWork
//
//  Created by WangXun on 2018/7/23.
//  Copyright © 2018年 WangXun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MJRefresh

// MARK: - View Model

/// Table View Controller的View Model基类
class BaseTableViewControllerViewModel: BaseViewControllerViewModel {
    
    // MARK: - Property
    
    // to view
    
    /// 数据源
    let dataSource = Variable<[SectionViewModelProtocol]?>(nil)
    
    /// 是否开启下拉刷新
    let isEnablePullRefresh = Variable<Bool>(false)
    /// 是否开启上拉加载更多
    let isEnablePushLoadmore = Variable<Bool>(false)
    /// 是否开启编辑Cell
    let isEnableEditCell = Variable<Bool>(false)
    
    /// 结束下拉刷新
    let callEndPullRefresh = PublishSubject<Void>()
    /// 结束上拉更多
    let callEndPushLoadMore = PublishSubject<Void>()
    
    /// 刷新table
    let callReload = PublishSubject<Void>()
    
    // from view
    
    /// 点击一行
    let didSelectRow = PublishSubject<IndexPath>()
    /// 提交删除一行
    let didCommitDeleteRow = PublishSubject<IndexPath>()
    
    /// 触发了下拉刷新
    let didPullRefresh = PublishSubject<Void>()
    /// 触发了上拉更多
    let didPushLoadMore = PublishSubject<Void>()
    
    // MARK: - Method
    
    override init() {
        super.init()
        
        dataSource.asObservable()
            .map({ (_) -> Void in })
            .bind(to: callReload)
            .disposed(by: disposeBag)
    }
    
    /// 根据section找到对应的section view model
    func fetchSectionViewModel(by section: Int) -> SectionViewModelProtocol? {
        return dataSource.value?.ew.element(of: section)
    }
    
    /// 根据indexPath找到对应的cell view model
    func fetchCellViewModel(by indexPath: IndexPath) -> TableViewCellViewModelProtocol? {
        
        return dataSource.value?.ew.element(of: indexPath.section)?.cellViewModels.ew.element(of: indexPath.row)
    }
}

// MARK: - View Controller

/// Table View Controller基类，可以使用MVVM
class BaseTableViewController: BaseViewController {
    
    // MARK: - Property
    
    /// tableview，可以用xib连接，也可以代码创建
    @IBOutlet weak var tableView: UITableView?
    
    // MARK: - Public Method
    
    /// 子类重写此方法，来指定cell的viewModel对应的view类型
    open func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        return BaseTableViewCell.self
    }
    
    /// 子类重写此方法，来指定section的viewModel对应的header view类型，返回空表示无header
    open func sectionHeaderClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        return nil
    }
    
    /// 子类重写此方法，来指定section的viewModel对应的footer view类型，返回空表示无footer
    open func sectionFooterClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        return nil
    }
    
    /// 子类重写此方法，在需要自定义时，返回一个的刷新用的header（当开启下拉刷新时）
    open func customRefreshHeaderClass() -> MJRefreshHeader.Type {
        return MJRefreshHeader.self
    }
    
    /// 子类重写此方法，在需要自定义时，返回一个刷新用的footer（当开启上拉更多时）
    open func customRefreshFooterClass() -> MJRefreshFooter.Type {
        return MJRefreshFooter.self
    }
    
    // MARK: - Life Cycle
    
    override func viewSetup() {
        super.viewSetup()
        
        /// table view 初始化
        if tableView == nil {   // 如果没有通过iboutlet连接，那么创建一个
            let aTableView = UITableView(frame: view.bounds, style: .plain)
            view.addSubview(aTableView)
            
            aTableView.separatorStyle = .none
            aTableView.dataSource = self
            aTableView.delegate = self
            
            tableView = aTableView
        }
        
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        guard let vm = viewModel as? BaseTableViewControllerViewModel else {
            return
        }
        
        /// 启用下拉刷新
        vm.isEnablePullRefresh
            .asDriver()
            .drive(onNext: { [weak self] (value) in
                self?.tableView?.mj_header = value == false ? nil : self?.creatRefreshHeader()
            })
            .disposed(by: disposeBag)
        
        /// 启用上拉更多
        vm.isEnablePushLoadmore
            .asDriver()
            .drive(onNext: { [weak self] (value) in
                self?.tableView?.mj_footer = value == false ? nil : self?.createRefreshFooter()
            })
            .disposed(by: disposeBag)
        
        /// 结束下拉刷新
        vm.callEndPullRefresh
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] (_) in
                self?.tableView?.mj_header.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        /// 结束上拉更多
        vm.callEndPushLoadMore
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] (_) in
                self?.tableView?.mj_footer.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        /// 刷新
        
        vm.callReload
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] (_) in
                self?.tableView?.reloadData()
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Private Method
    
    /// 创建下拉控件
    private func creatRefreshHeader() -> MJRefreshHeader? {
        
        let headerView = customRefreshHeaderClass().init(refreshingBlock: { [weak self] in
            (self?.viewModel as? BaseTableViewControllerViewModel)?.didPullRefresh.onNext(())
        })
        
        return headerView
    }
    
    /// 创建上拉卡控件
    private func createRefreshFooter() -> MJRefreshFooter? {
        
        let footerView = customRefreshFooterClass().init(refreshingBlock: { [weak self] in
            (self?.viewModel as? BaseTableViewControllerViewModel)?.didPushLoadMore.onNext(())
        })
        
        return footerView
    }
    
}


// MARK: - TableView DataSource, Delegate
extension BaseTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let dataSourceValue = (viewModel as? BaseTableViewControllerViewModel)?.dataSource.value else {
            return 0
        }
        
        return dataSourceValue.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard var sectionVM = (viewModel as? BaseTableViewControllerViewModel)?.fetchSectionViewModel(by: section) else {
            return 0
        }
        
        sectionVM.callReloadSection = { [weak tableView] in
            tableView?.reloadSections([section], with: .automatic)
        }
        
        return sectionVM.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard var cellVM = (viewModel as? BaseTableViewControllerViewModel)?.fetchCellViewModel(by: indexPath) else {
            return UITableViewCell()
        }
        
        guard let cellClass = self.cellClass(from: cellVM) else {
            return UITableViewCell()
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellClass.reuseID(with: cellVM))
        
        if cell == nil {
            cell = cellClass.createInstance(with: cellVM)
        }
        
        (cell as? TableCellCompatible)?.updateView(with: cellVM)
        
        cellVM.callReloadCell = { [weak tableView] in
            tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
        
        return cell ?? UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let cellVM = (viewModel as? BaseTableViewControllerViewModel)?.fetchCellViewModel(by: indexPath) else {
            return 0
        }
        
        guard let cellClass = self.cellClass(from: cellVM) else {
            return 0
        }
        
        return cellClass.height(with: cellVM, tableSize: tableView.bounds.size)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        (viewModel as? BaseTableViewControllerViewModel)?.didSelectRow.onNext(indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionVM = (viewModel as? BaseTableViewControllerViewModel)?.fetchSectionViewModel(by: section) else {
            return nil
        }
        
        guard let sectionHeaderClass = sectionHeaderClass(from: sectionVM) else {
            return nil
        }
        
        let reuseID = sectionHeaderClass.reuseID(with: sectionVM)
        
        var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID)
        
        if headerView == nil {
            headerView = sectionHeaderClass.createInstance(with: sectionVM)
        }
        
        (headerView as? SectionViewCompatible)?.updateView(with: sectionVM)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let sectionVM = (viewModel as? BaseTableViewControllerViewModel)?.fetchSectionViewModel(by: section) else {
            return 0
        }
        
        guard let sectionHeaderClass = sectionHeaderClass(from: sectionVM) else {
            return 0
        }
        
        return sectionHeaderClass.height(with: sectionVM, tableSize: tableView.bounds.size)
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let sectionVM = (viewModel as? BaseTableViewControllerViewModel)?.fetchSectionViewModel(by: section) else {
            return nil
        }
        
        guard let sectionFooterClass = sectionFooterClass(from: sectionVM) else {
            return nil
        }
        
        let reuseID = sectionFooterClass.reuseID(with: sectionVM)
        
        var footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID)
        
        if footerView == nil {
            footerView = sectionFooterClass.createInstance(with: sectionVM)
        }
        
        (footerView as? SectionViewCompatible)?.updateView(with: sectionVM)
        
        return footerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        guard let sectionVM = (viewModel as? BaseTableViewControllerViewModel)?.fetchSectionViewModel(by: section) else {
            return 0
        }
        
        guard let sectionFooterClass = sectionFooterClass(from: sectionVM) else {
            return 0
        }
        
        return sectionFooterClass.height(with: sectionVM, tableSize: tableView.bounds.size)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (viewModel as? BaseTableViewControllerViewModel)?.isEnableEditCell.value ?? false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return (viewModel as? BaseTableViewControllerViewModel)?.isEnableEditCell.value == true ? "删除" : nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            (viewModel as? BaseTableViewControllerViewModel)?.didCommitDeleteRow.onNext(indexPath)
        }
    }
    
    
}
