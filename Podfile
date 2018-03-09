source 'https://github.com/jjochen/podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

#Installing Nimble 5.1.1 (was 7.0.3)
#Installing Quick 1.1.0 (was 1.2.0)
#Installing Realm 2.5.1 (was 3.1.1)
#Installing RealmSwift 2.5.1 (was 3.1.1)
#Installing RxBlocking 3.4.0 (was 4.1.2)
#Installing RxCocoa 3.4.0 (was 4.1.2)
#Installing RxDataSources 1.0.3 (was 3.0.2)
#Installing RxNimble 1.0.0 (was 4.1.0)
#Installing RxRealm 0.6.0 (was 0.7.5)
#Installing RxSwift 3.4.0 (was 4.1.2)
#Installing RxTest 3.4.0 (was 4.1.2)
#Installing SwiftFormat 0.28.2 (was 0.33.4)
#Installing Zip 0.7.0 (was 1.1.0)

target 'PhotoStickers' do
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'RealmSwift'
    pod 'RxRealm'
    pod 'Log'
    pod 'SwiftFormat/CLI'
    pod 'Zip'
    
    #pod 'RxSwiftExt'
    #pod 'RxCoreData'
    #pod 'RxViewModel'
    #pod 'RxOptional'
    #pod 'SnapKit'
    #pod 'Toaster'

    target 'PhotoStickersTests' do
        inherit! :search_paths
        
        pod 'RxTest'
        pod 'RxBlocking'
        pod 'Quick'
        pod 'Nimble'
        pod 'RxNimble'
    end
end

target 'MessageExtension' do
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'RealmSwift'
    pod 'RxRealm'
    pod 'Log'
    pod 'Zip'
end


