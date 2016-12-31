source 'https://github.com/jjochen/podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!


target 'PhotoStickers' do
    pod 'RxSwift', '~> 3.0'
    pod 'RxCocoa', '~> 3.0'
    pod 'RxDataSources', '~> 1.0'
    pod 'RxCoreData'
    #pod 'RxViewModel'
    #pod 'RxOptional'
    #pod 'RealmSwift'
    #pod 'SnapKit'
    pod 'Log'
    pod 'Toaster'

    target 'PhotoStickersTests' do
        inherit! :search_paths
        pod 'RxTest',     '~> 3.0'
        pod 'RxBlocking', '~> 3.0'
        #pod 'Quick'
        #pod 'Nimble'
        #pod 'RxNimble'
    end
end

target 'MessageExtension' do
    pod 'RxSwift', '~> 3.0'
    pod 'RxCocoa', '~> 3.0'
    pod 'RxDataSources', '~> 1.0'
    pod 'RxCoreData'
    #pod 'RxViewModel'
    #pod 'RxOptional'
    #pod 'RealmSwift'
    #pod 'SnapKit'
    pod 'Log'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

