Pod::Spec.new do |s|

  s.name         = "EndlessWork"
  s.version      = "0.0.3"
  s.summary      = "A Framework used in MVVM project"

  s.homepage     = "https://github.com/J219/EndlessWork"

  s.license      = "MIT"

  s.static_framework = false

  s.author             = { "J219" => "end1988@126.com" }

  s.ios.deployment_target = '8.0'

  # s.source       = { :git => "https://github.com/J219/EndlessWork.git", :tag => "#{s.version}" }
  s.source       = { :git => "https://github.com/J219/EndlessWork.git" }

  s.source_files  = "Source", "Source/**/*.{h,m,swift}"

  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'FMDB'
  s.dependency 'HandyJSON', '~> 4.1.1'
  s.dependency 'SwiftyJSON'
  s.dependency 'MGJRouter', '~>0.9.0'
  s.dependency 'RxSwift',    '~> 4.0'
  s.dependency 'RxCocoa',    '~> 4.0'


end
