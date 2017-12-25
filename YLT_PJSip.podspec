
Pod::Spec.new do |s|
  s.name             = 'YLT_PJSip'
  s.version          = '0.0.13'
  s.summary          = 'A short description of YLT_PJSip.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/YLTTeam/YLT_PJSip'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xphaijj0305@126.com' => 'xiangph@qtec.cn' }
  s.source           = { :git => 'https://github.com/YLTTeam/YLT_PJSip.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files        =   'YLT_PJSip/Classes/include/**/*.h'

  s.public_header_files =   'YLT_PJSip/Classes/include/**/*.h'

  s.preserve_paths      = 'YLT_PJSip/Classes/include/**/*{h,hpp}'

  s.vendored_libraries  = 'YLT_PJSip/Classes/lib/*.a'

  s.xcconfig            = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'PJ_AUTOCONF=1',
      'HEADER_SEARCH_PATHS'          => '$(inherited) $(PODS_ROOT)/YLT_PJSip/Classes/include'
  }
  s.frameworks          = 'CFNetwork', 'AudioToolbox', 'AVFoundation', 'CoreMedia'
  s.libraries           = 'stdc++'
  s.header_mappings_dir = 'YLT_PJSip/Classes/include'
  # s.requires_arc = true
  #s.dependency 'YLT_BaseLib'

end
