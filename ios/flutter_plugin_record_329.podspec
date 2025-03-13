#use_frameworks!
Pod::Spec.new do |s|
  s.name             = 'flutter_plugin_record_329'
  s.version          = '0.0.1'
  s.summary          = '使用Flutter实现 仿微信录音的插件 支持 Flutter 3.29'
  s.description      = <<-DESC
使用Flutter实现 仿微信录音的插件 支持 Flutter 3.29
                       DESC
  s.homepage         = 'http://icxl.xyz'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'XIN_LEI' => 'xinlei_coder@aliyun.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,mm}'
  s.public_header_files = 'Classes/**/*.h'
#  s.vendored_libraries = 'Classes/libopencore-amrnb.a'
  s.dependency 'Flutter'
  s.framework  = "AVFoundation"
  s.ios.deployment_target = '12.0'

  # 添加隐私权限描述
  s.info_plist = {
    'NSMicrophoneUsageDescription' => '需要访问麦克风来录制音频',
    'NSDocumentsFolderUsageDescription' => '需要访问文档文件夹来保存录音文件'
  }
end