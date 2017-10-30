
Pod::Spec.new do |s|
  s.name             = 'YLT_PJSip'
  s.version          = '0.0.1'
  s.summary          = 'A short description of YLT_PJSip.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/YLTTeam/YLT_PJSip'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xphaijj0305@126.com' => 'xiangph@qtec.cn' }
  s.source           = { :git => 'https://github.com/YLTTeam/YLT_PJSip.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  


end
