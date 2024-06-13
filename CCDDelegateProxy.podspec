Pod::Spec.new do |spec|

  spec.name         = "CCDDelegateProxy"
  spec.version      = "0.0.1"
  spec.summary      = "DelegateProxy: 委托拦截，重新转发，实现无侵入的逻辑能力"

  spec.description  = <<-DESC
			委托拦截，重新转发，实现无侵入的逻辑能力；比如：日志跟踪；
                   DESC

  spec.homepage     = "https://github.com/zhu410289616/DelegateProxy"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "zhu410289616" => "zhu410289616@163.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/zhu410289616/DelegateProxy.git", :tag => "#{spec.version}" }
  
  spec.default_subspec = "Core", "URLSessionProxy"
  
  spec.subspec "Core" do |cs|
    cs.source_files = "Pod/Core/**/*.{h,m,mm}"
  end
  
  spec.subspec "URLSessionProxy" do |cs|
    cs.source_files = "Pod/URLSessionProxy/**/*.{h,m,mm}"
    cs.libraries = "c++"
  end

end
