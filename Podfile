source 'https://github.com/jjochen/podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

deployment_target = '13.0'
platform :ios, deployment_target
use_frameworks!
inhibit_all_warnings!

target 'PhotoStickers' do
    # pod 'RxSwift'
    # pod 'RxCocoa'
    # pod 'RxDataSources'
    # pod 'RealmSwift'
    # pod 'RxRealm'
    # pod 'Log'
    # pod 'SwiftFormat/CLI'
    # pod 'Zip'

    # pod 'SnapKit'
    # pod 'Toaster'

    # target 'PhotoStickersTests' do
    #     inherit! :search_paths
    #
    #     pod 'RxTest'
    #     pod 'RxBlocking'
    #     pod 'Quick'
    #     pod 'Nimble'
    #     pod 'RxNimble'
    # end
end

target 'MessagesExtension' do
    pod 'SwiftFormat/CLI'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'RealmSwift'
    pod 'RxRealm'
    pod 'RxFlow', '>= 2.0.0'
    pod 'RxOptional'
    pod 'RxViewController'
#    pod 'RxMediaPicker'
    pod 'RxSwiftExt'
    pod 'Log'
    pod 'Zip'
    pod 'Reusable'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
    end
  end
end
