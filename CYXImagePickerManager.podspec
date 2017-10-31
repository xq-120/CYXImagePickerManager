Pod::Spec.new do |s|
  s.name = 'CYXImagePickerManager'
  s.version = '0.0.2'

  s.ios.deployment_target = '8.0'

  s.license = 'MIT'
  s.summary = '图片选择器封装.'
  s.homepage = 'https://github.com/xq-120/CYXImagePickerManager.git'
  s.author = { 'xq-120' => '1204556447@qq.com' }
  s.source = { :git => 'https://github.com/xq-120/CYXImagePickerManager.git', :tag => s.version.to_s }

  s.description = '一句话搞定图片选择.'

  s.requires_arc = true
  s.frameworks = 'Foundation', 'UIKit'

  s.source_files  = 'CYXImagePickerManager/*.{h,m}'

  s.dependency 'TZImagePickerController', '~> 1.9.3'
end

