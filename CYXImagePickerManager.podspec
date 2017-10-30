Pod::Spec.new do |s|
  s.name = 'CYXImagePickerManager'
  s.version = '0.0.1'

  s.ios.deployment_target = '8.0'

  s.license = 'MIT'
  s.summary = '图片选择器封装.'
  s.homepage = 'https://github.com/xq-120/CYXImagePickerManager.git'
  s.author = { 'xq-120' => '1204556447@qq.com' }
  s.source = { :git => 'https://github.com/xq-120/CYXImagePickerManager.git', :tag => s.version.to_s }

  s.description = '一句话搞定图片选择.'

  s.requires_arc = true
  s.frameworks = 'Foundation', 'UIKit'
  
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'CYXImagePickerManager/*'
  end

  s.subspec 'XQSheet' do |sheet|
    sheet.ios.deployment_target = '7.0'
    sheet.source_files = 'CYXImagePickerManager/XQSheet/*.{h,m}'
    sheet.dependency 'CYXImagePickerManager/Core'
    sheet.dependency 'XQSheet', '~> 1.0.3'
    sheet.xcconfig = {
      'USER_HEADER_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/XQSheet/XQSheet'
    }
  end

  s.subspec 'TZImagePickerController' do |picker|
    picker.ios.deployment_target = '7.0'
    picker.source_files = 'CYXImagePickerManager/TZImagePickerController/*'
    picker.dependency 'CYXImagePickerManager/Core'
    picker.dependency 'TZImagePickerController', '~> 1.9.3'
    picker.xcconfig = {
      'USER_HEADER_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/TZImagePickerController/TZImagePickerController'
    }
  end

end

