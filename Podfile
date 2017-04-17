source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

def available_pods
  pod 'Alamofire', '~> 4.0'
  pod 'HanekeSwift',
    :git => 'https://github.com/Haneke/HanekeSwift.git',
    :branch => 'feature/swift-3'
  pod 'GPUImage'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  # Pods for Capture
  pod 'Locksmith', '~> 3.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'ReachabilitySwift'
  pod 'TwitterKit'
end

target 'Capture' do
  inherit! :search_paths
  available_pods
end

target 'Capture_Dev' do
  inherit! :search_paths
  available_pods
end

post_install do |installer|
  installer.pods_project.targets.each  do |target|
      target.build_configurations.each  do |config| config.build_settings['SWIFT_VERSION'] = '3.0'
      end
   end
end
