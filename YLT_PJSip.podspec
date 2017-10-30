
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

  s.ios.deployment_target = '8.0'
  s.source_files = ['YLT_PJSip/Classes/**/*.{h,m}','YLT_PJSip/Classes/include/**/*.{h,m}']
  s.public_header_files = ['YLT_PJSip/Classes/**/*.h','YLT_PJSip/Classes/include/**/*.h']
  s.preserve_paths = ['YLT_PJSip/Classes/**/*','YLT_PJSip/Classes/include/**/*']
  s.vendored_libraries = 'YLT_PJSip/Classes/lib/*.a'

  header_search_paths   =['"$(PODS_ROOT)/Headers/Public/YLT_PJSip/pjlib/include"',
                          '"$(PODS_ROOT)/Headers/Public/YLT_PJSip/pjlib-util/include"',
                          '"$(PODS_ROOT)/Headers/Public/YLT_PJSip/pjmedia/include"',
                          '"$(PODS_ROOT)/Headers/Public/YLT_PJSip/pjnath/include"',
                          '"$(PODS_ROOT)/Headers/Public/YLT_PJSip/pjsip/include"']
  s.xcconfig            = {
      'HEADER_SEARCH_PATHS'          => header_search_paths.join(' '),
      'GCC_PREPROCESSOR_DEFINITIONS' => 'PJ_AUTOCONF=1'
  }
  s.frameworks          = 'CFNetwork', 'AudioToolbox', 'AVFoundation', 'CoreMedia'
  s.libraries           = 'stdc++'
  s.header_mappings_dir = 'YLT_PJSip/Classes/include'
end
