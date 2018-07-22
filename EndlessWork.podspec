Pod::Spec.new do |s|

  s.name         = "EndlessWork"
  s.version      = "0.0.3"
  s.summary      = "A Framework used in MVVM project"

  s.homepage     = "https://github.com/J219/EndlessWork"

  s.license      = "MIT"

  s.static_framework = false

  s.author             = { "J219" => "end1988@126.com" }

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/J219/EndlessWork.git", :tag => "#{s.version}" }

  s.source_files  = "Source", "Source/**/*.{h,m,swift}"

end
