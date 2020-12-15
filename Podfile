#platform :ios, '11.0'

target 'SmartEducation' do
  use_frameworks!

  pod 'Alamofire'
  pod 'SDWebImage'
  pod 'SwiftLint'
  pod 'Closures'
  pod 'Swinject'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SwinjectAutoregistration'
  pod 'SmartHitTest'
  pod 'JitsiMeetSDK', '~> 2.11.0'
  pod 'IQKeyboardManagerSwift'
  pod 'SnapKit', '~> 5.0.0'
  pod 'OSSSpeechKit'
  pod 'AppCenter'
  pod 'MessageKit'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
    end
  end

  target 'SmartEducationTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SmartEducationUITests' do
    # Pods for testing
  end

end
