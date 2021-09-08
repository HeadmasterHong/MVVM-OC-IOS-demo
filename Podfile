# Uncomment the next line to define a global platform for your project
source 'http://gitlab.tools.vipshop.com/ios-shared/vipods.git'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'NoStoryBoard2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'AFNetworking'
  pod 'YYModel'
  pod 'ReactiveObjC'
  pod 'FMDB'
  pod 'Masonry'
  pod 'LightArt', '~> 1.3.0.2', :subspecs => ['noYYModel', 'withYYModel'] 
  pod 'SDWebImage', '~> 4.3.1'
  # Pods for NoStoryBoard2

  target 'NoStoryBoard2Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NoStoryBoard2UITests' do
    # Pods for testing
  end

end
