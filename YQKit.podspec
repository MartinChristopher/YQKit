#
# Be sure to run `pod lib lint YQKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YQKit'
  s.version          = '0.0.2'
  s.summary          = 'A short description of YQKit.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
                       
  s.homepage         = 'https://github.com/MartinChristopher/YQKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MartinChristopher' => '519483040@qq.com' }
  s.source           = { :git => 'https://github.com/MartinChristopher/YQKit.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  s.platform              = :ios, "9.0"
  
  s.subspec 'YQAudio' do |audio|
  audio.source_files = 'YQKit/Classes/YQAudio/**/*'
  end
  
  s.subspec 'YQAppPurchase' do |purchase|
  purchase.source_files = 'YQKit/Classes/YQAppPurchase/**/*'
  end
  
  s.subspec 'YQActionSheet' do |sheet|
  sheet.source_files = 'YQKit/Classes/YQActionSheet/**/*'
  end
  
  s.subspec 'YQFlowLayout' do |layout|
  layout.source_files = 'YQKit/Classes/YQFlowLayout/**/*'
  end
  
  s.subspec 'YQPageControl' do |yqpage|
  yqpage.source_files = 'YQKit/Classes/YQPageControl/**/*'
  end
  
  s.subspec 'WOPageControl' do |wopage|
  wopage.source_files = 'YQKit/Classes/WOPageControl/**/*'
  end
  
  s.subspec 'YQWaterFallLayout' do |waterLayout|
  waterLayout.source_files = 'YQKit/Classes/YQWaterFallLayout/**/*'
  end
  
  s.subspec 'PagingEnableLayout' do |pageLayout|
  pageLayout.source_files = 'YQKit/Classes/PagingEnableLayout/**/*'
  end
  
  s.subspec 'XJSwitch' do |switch|
  switch.source_files = 'YQKit/Classes/XJSwitch/**/*'
  end
  
  # s.resource_bundles = {
  #   'YQKit' => ['YQKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
