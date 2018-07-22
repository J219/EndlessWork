//
//  BaseViewController.swift
//  SmartHomeV6
//
//  Created by WangXun on 2018/7/22.
//  Copyright © 2018年 WangXun. All rights reserved.
//
//  ViewController基类

import UIKit
import RxSwift
import RxCocoa

/// 等待框状态
class LoadingState {
    
    /// 是否在等待
    var isLoading = false
    /// 等待的文案
    var loadingText: String? = nil
    
    /// 没有等待中
    static var noLoading: LoadingState { return LoadingState(isLoading: false, loadingText: nil) }
    
    init(isLoading: Bool, loadingText: String?) {
        self.isLoading = isLoading
        self.loadingText = loadingText
    }
    
    convenience init(loadingInfo: LoadingInfo?) {
        self.init(isLoading: loadingInfo != nil, loadingText: loadingInfo?.text)
    }
}

/// 等待框信息
class LoadingInfo: Equatable {
    
    /// 等待的文案
    var text: String? = nil
    /// 等待的超时时间
    var timeout: TimeInterval? = nil
    /// 超时的错误信息
    var timeoutError: String? = nil
    
    /// 结束事件，bool值表示是否超时
    let endLoading = PublishSubject<Bool>()
    
    /// 超时的事件
    private var timeoutRx: Observable<Void>?
    /// 监听回收袋
    private var disposeBag = DisposeBag()
    
    /// 初始化
    init(text: String? = nil,
         timeout: TimeInterval? = nil,
         timeoutError: String? = nil) {
        
        self.text = text
        self.timeout = timeout
        self.timeoutError = timeoutError
        
    }
    
    /// 调用开始，返回一个超时事件（可能为空）
    func start() -> Observable<Void> {
        if let timeoutValue = timeout {
            
            /// 发送一个15秒后超时的消息，如果之后收到设备信息更新，则结束等待框，弹出错误提示
            let timeoutRx = Observable.just(())
                .delay(timeoutValue, scheduler: MainScheduler.instance)
            
            /// 持有
            self.timeoutRx = timeoutRx
            
            return timeoutRx
        } else {
            return Observable.empty()
        }
    }
    
    /// 调用结束
    func end(byTimeout isTimeOut: Bool) {
        
        /// 回收掉超时事件的监听
        disposeBag = DisposeBag()
        timeoutRx = nil
        endLoading.onNext(isTimeOut)
    }
    
    
    // Equatable
    public static func == (lhs: LoadingInfo, rhs: LoadingInfo) -> Bool {
        
        return lhs.text == rhs.text
            && lhs.timeout == rhs.timeout
            && lhs.timeoutError == rhs.timeoutError
    }
    
}

/// 弹框数据
struct AlertMessage {
    
    /// 提示框类型
    enum AlertType {
        /// 无
        case none
        /// 弹框
        case alert
        /// toast
        case toast
    }
    
    /// 提示信息
    var message: String?
    
    /// 提示信息的方式
    var alertType: AlertType = .none
    
    /// 确认按钮标题
    var alertButtonTitle = "确定"
    
    /// 空白无提示
    static let noMessage = AlertMessage(message: nil, alertType: .none)
    
    /// 初始化
    init(message: String?, alertType: AlertType, alertButtonTitle: String? = nil) {
        self.message = message
        self.alertType = alertType
        self.alertButtonTitle = alertButtonTitle ?? "确定"
    }
}

/// 点击确认或取消的弹框数据
struct ConfirmAlertMessage {
    
    /// 是否显示
    var isShow = true
    
    /// 标题
    var title: String?
    /// 信息
    var message: String?
    /// 取消按钮标题
    var cancelButtonTitle: String?
    /// ok按钮标题
    var okButtonTitle: String?
    
    /// 初始化
    init(isShow: Bool = true, title: String? = nil, message: String? = nil, cancelButtonTitle: String? = "取消", okButtonTitle: String? = "确定") {
        self.isShow = isShow
        self.title = title
        self.message = message
        self.cancelButtonTitle = cancelButtonTitle
        self.okButtonTitle = okButtonTitle
    }
    
    /// 一个默认的不展示实例
    static var none: ConfirmAlertMessage { return ConfirmAlertMessage(isShow: false, title: nil, message: nil, cancelButtonTitle: nil, okButtonTitle: nil) }
    
    /// 直接通过message创建，其他取默认值
    static func byMessage(_ message: String) -> ConfirmAlertMessage {
        
        return ConfirmAlertMessage(isShow: true, title: nil, message: message, cancelButtonTitle: "取消", okButtonTitle: "取消")
    }
}

/// 弹出picker的数据
struct PickerShowMessage {
    
    /// 可选的数据
    var message: [String] = []
    
    /// 默认选中的index
    var index: Int? = 0
    
}

// MARK: - View Model

/// ViewController基类的ViewModel
class BaseViewControllerViewModel: NSObject {
    
    // MARK: - Property
    
    /// rx使用的DisposeBag
    let disposeBag = DisposeBag()
    
    // event from view
    let viewDidLoad = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()
    let viewDidAppear = PublishSubject<Void>()
    let viewWillDisappear = PublishSubject<Void>()
    let viewDeinit = PublishSubject<Void>()
    
    // event to view
    
    /// view的等待框状态
    let isShowLoading = Variable<LoadingState>(.noLoading)
    /// 开始一项等待，可以叠加，等待文字会显示为最新的等待文字
    let startOneLoading = PublishSubject<LoadingInfo>()
    /// 结束一项等待（如果传入nil时会结束最早开始的等待），当所有等待都结束时，等待框会消失
    let endOneLoading = PublishSubject<LoadingInfo?>()
    /// 标题
    let navTitle = Variable<String?>(nil)
    
    /// 弹框
    let showMessage = PublishSubject<AlertMessage>()
    /// 返回
    let goBack = PublishSubject<Void>()
    /// 打开路由，参数为页面路由类型和infoDic
    let openRouter = PublishSubject<(RouterPageProtocol?, [String: Any]?)>()
    
    // MARK: - Private Property
    
    /// 等待框缓存区
    private var loadingCache = [LoadingInfo]()
    
    
    // MARK: - Life Cycle
    
    override init() {
        super.init()
        
        startOneLoading.asObservable()
            .observeOn(MainScheduler.instance)
            .map({ [weak self] (value) -> LoadingState in
                return self?.addOneLoading(value) ?? .noLoading
            })
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        endOneLoading.asObservable()
            .observeOn(MainScheduler.instance)
            .map({ [weak self] (value) -> LoadingState in
                return self?.removeOneLoading(value) ?? .noLoading
            })
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
    }
    
    deinit {
        print("view model析构:\(self)")
    }
    
    
    // MARK: - Private Method
    
    /// 添加一个loading
    private func addOneLoading(_ info: LoadingInfo) -> LoadingState {
        
        loadingCache.append(info)
        
        info.start().asObservable()
            .map({ [weak self, weak info] (_) -> LoadingState in
                return self?.removeOneLoading(info, isTimeout: true) ?? .noLoading
            })
            .bind(to: isShowLoading)
            .disposed(by: disposeBag)
        
        return LoadingState(loadingInfo: info)
    }
    
    /// 移除一个loading
    private func removeOneLoading(_ info: LoadingInfo?, isTimeout: Bool = false) -> LoadingState {
        
        if isTimeout {
            loadingTimeout(info)
        }
        
        info?.end(byTimeout: isTimeout)
        
        // 删除
        var idxToRemove: Int? = nil
        
        if let infoValue = info {
            idxToRemove = loadingCache.index(of: infoValue)
        }
        
        if idxToRemove == nil && loadingCache.isEmpty == false {
            idxToRemove = 0 // 删除最早的那个
        }

        if let idxToRemoveValue = idxToRemove {
            _ = loadingCache.remove(at: idxToRemoveValue)
        }
        
        return LoadingState(loadingInfo: loadingCache.last)
        
    }
    
    /// 等待框超时的处理
    private func loadingTimeout(_ info: LoadingInfo?) {
        
        if let timeoutErr = info?.timeoutError {
            self.showMessage.onNext(AlertMessage(message: timeoutErr, alertType: .toast))
        }
    }
    
}

// MARK: - View Controller

/// ViewController基类，可以使用MVVM
class BaseViewController: UIViewController {
    
    // MARK: - Public Property
    
    /// view model，可选
    var viewModel: BaseViewControllerViewModel? {
        didSet {
            if viewIsLoad {
                viewBindViewModel()
            }
        }
    }
    
    /// 是否加载完毕
    var viewIsLoad = false
    
    /// rx使用的DisposeBag
    var disposeBag = DisposeBag()
    
    /// 使用的路由实例
    var router: RouterManager?
    
    // MARK: - Public Method
    
    /// 重写这个方法，设置等待框样式
    open func showLoading(withText text: String) {
        
    }
    
    /// 重写这个方法，隐藏等待框
    open func hideLoading() {
        
    }
    
    /// 重写这个方法，设置弹框样式
    open func showAlert(_ message: AlertMessage) {
        
    }
    
    /// 重写这个方法，在里面初始化相关view，会在ViewDidLoad中，viewBindViewModel之前调用
    open func viewSetup() {
        
    }
    
    /// 重写并在这个方法里绑定view和view model，默认在ViewDidLoad中，viewSetup之后调用
    open func viewBindViewModel() {
        
        /// view model 绑定
        if let viewModel = viewModel {
            
            /// 重制回收袋
            disposeBag = DisposeBag()
            
            /// 等待框
            viewModel.isShowLoading
                .asDriver()
                .drive(onNext: { [weak self] (value) in
                    if value.isLoading {
                        self?.showLoading(withText: value.loadingText ?? "")
                    } else {
                        self?.hideLoading()
                    }
                })
                .disposed(by: disposeBag)
            
            /// 提示框
            viewModel.showMessage
                .asDriver(onErrorJustReturn: AlertMessage(message: nil, alertType: .none))
                .delay(0.1) // 避免和等待框结束的冲突
                .drive(onNext: { [weak self] (value : AlertMessage) in
                    self?.showAlert(value)
                })
                .disposed(by: disposeBag)
            
            /// 标题
            viewModel.navTitle
                .asDriver()
                .drive(self.navigationItem.rx.title)
                .disposed(by: disposeBag)
            
            // 返回
            viewModel.goBack
                .asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] (_) in
                    _ = self?.navigationController?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
            
            /// 页面路由跳转
            viewModel.openRouter
                .asDriver(onErrorJustReturn: ((nil, nil)))
                .drive(onNext: { [weak self] (page,dic) in
                    self?.openRouter(page:page, infoDic: dic)
                })
                .disposed(by: disposeBag)
        }
        
    }
    
    
    /// 打开页面路由
    ///
    /// - Parameters:
    ///   - page: 具体的页面操作
    ///   - infoDic: 附带的属性
    func openRouter(page: RouterPageProtocol?, infoDic: [String: Any]?) {
        
        guard let pageValue = page else {
            return
        }
        
        router?.openRouter(page: pageValue, infoDic: infoDic) { [weak self] (completionObj) -> Bool in
            
            var processResult = true
            
            if let toastStr = completionObj.message {
//                self?.view.showTextHUD(toastStr, rect: self!.view.bounds)
                self?.showAlert(AlertMessage(message: toastStr, alertType: .toast))
            }
            
            switch completionObj.jumpType {
            case .none, .block:
                break;
            case .push:
                if let vc = completionObj.controller {
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    processResult = false
                }
            case .pop:
                self?.navigationController?.popViewController(animated: true)
            case .popToRoot:
                self?.navigationController?.popToRootViewController(animated: true)
            case .popToController:
                if let cls = completionObj.popToControllerType {
                    var targetVC: UIViewController? = nil
                    for vc in self?.navigationController?.viewControllers ?? [] {
                        if vc.isKind(of: cls) {
                            targetVC = vc
                            break
                        }
                    }
                    if let targetVCValue = targetVC {
                        self?.navigationController?.popToViewController(targetVCValue, animated: true)
                    }
                    
                }
            case .modal:
                if let vc = completionObj.controller {
                    self?.present(vc, animated: true, completion: nil)
                } else {
                    processResult = false
                }
            case .dismiss:
                self?.dismiss(animated: true, completion: nil)
                
            case .subview:
                if let aSubview = completionObj.view, let sSelf = self {
                    aSubview.frame = sSelf.view.bounds
                    aSubview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    sSelf.view.addSubview(aSubview)
                }
            }
            
            return processResult
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// view setup
        self.viewSetup()
        
        if viewModel != nil {
            
            /// view绑定viewModel
            self.viewBindViewModel()
        }
        
        viewIsLoad = true
        
        /// viewdidload事件
        viewModel?.viewDidLoad.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel?.viewWillAppear.onNext(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel?.viewDidAppear.onNext(())
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.viewModel?.viewWillDisappear.onNext(())
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
    }
    
    deinit {
        
        self.viewModel?.viewDeinit.onNext(())
        
        print("view controller析构:\(self)")
    }
    
    // MARK: - 界面属性定制
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - 转屏
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // MARK: - Private Method
    
    
    
}
