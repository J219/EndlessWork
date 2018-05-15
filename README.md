# EndlessWork
一个快速搭建的MVVM框架。

# 网络
网络层采用Alamofire作为底层数据，在其之上提供数据访问层，与业务对接。

# 数据库
网络层采用FMDB作为底层数据，在其之上提供数据访问层，与业务对接。

# MVVM
通过响应式框架RxSwift来实现MVVM，在ViewController基类中添加了对于MVVM的支持。

# 路由
路由层选择MGJRouter作为底层组件支持，路由层在解析ViewController发出的路由请求之后，解析，并讲处理结果返回给ViewController

