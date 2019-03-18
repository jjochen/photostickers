//
//  PhotosStickerBrowserViewController.swift
//  Photo Stickers
//
//  Created by Jochen Pfeiffer on 25/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import Messages
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class PhotoStickerBrowserViewController: MSMessagesAppViewController {
    lazy var viewModel: PhotoStickerBrowserViewModelType = {
        #if DEBUG
            let isRunningUITests = true
        #else
            // TODO:
            let isRunningUITests = UserDefaults.standard.bool(forKey: "RunningUITests")
        #endif
        let dataFolderType: DataFolderType = isRunningUITests ? .appGroupPrefilled(subfolder: "UITests") : .appGroup
        let dataFolder: DataFolderServiceType = DataFolderService(type: dataFolderType)
        let imageStoreService: ImageStoreServiceType = ImageStoreService(url: dataFolder.imagesURL)
        let stickerService: StickerServiceType = StickerService(realmType: .onDisk(url: dataFolder.realmURL), imageStoreService: imageStoreService)
        let stickerRenderService: StickerRenderServiceType = StickerRenderService()

        return PhotoStickerBrowserViewModel(stickerService: stickerService, imageStoreService: imageStoreService, stickerRenderService: stickerRenderService, extensionContext: self.extensionContext)
    }()

    fileprivate let disposeBag = DisposeBag()

    // MARK: Outlets / Actions

    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        view.tintColor = StyleKit.appColor
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Bindings

    fileprivate func setupBindings() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<StickerSection>(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case let .stickerItem(viewModel: cellViewModel):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier.StickerBrowserCell.rawValue, for: indexPath) as! StickerBrowserCell
                    cell.viewModel = cellViewModel
                    return cell
                }
            }
        )
        dataSource.configureSupplementaryView = { _, collectionView, kind, indexPath in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionReusableViewReuseIdentifier.StickerBrowserButtonView.rawValue, for: indexPath) as! StickerBrowserButtonView
            return view
        }

        viewModel.sectionItems
            .map { items in
                [StickerSection(stickers: items)]
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

//        collectionView.rx
//            .modelSelected(StickerSectionItem.self)
//            .filter { $0 == .openAppItem }
//            .subscribe(onNext: { [weak self] _ in
//                self?.viewModel?.openApp()
//            })
//            .disposed(by: disposeBag)
    }
}

// MARK: - Conversation Handling

extension PhotoStickerBrowserViewController {
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
    }

    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        super.didReceive(message, conversation: conversation)
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        super.didStartSending(message, conversation: conversation)
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        super.didCancelSending(message, conversation: conversation)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
    }
}

extension PhotoStickerBrowserViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> PhotoStickerBrowserViewController {
        let viewController = storyboard.viewController(withID: .PhotoStickerBrowserViewController) as! PhotoStickerBrowserViewController
        return viewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        func getEditStickerViewController(from segue: UIStoryboardSegue) -> EditStickerViewController {
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! EditStickerViewController
            return viewController
        }

        if segue == .AddStickerSegue {
            let viewController = getEditStickerViewController(from: segue)
            viewController.viewModel = viewModel.addStickerViewModel()
        } else if segue == .EditStickerSegue {
            let cell = sender as! StickerBrowserCell
            guard let sticker = cell.viewModel?.sticker else {
                Logger.shared.error("Cell has no sticker!")
                return
            }
            let viewController = getEditStickerViewController(from: segue)
            viewController.viewModel = viewModel.editStickerViewModel(for: sticker)
        }
    }
}

// MARK: Skinning

extension PhotoStickerBrowserViewController {}

extension PhotoStickerBrowserViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension PhotoStickerBrowserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return StickerFlowLayout.itemSize(in: collectionView.bounds)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return StickerFlowLayout.sectionInsets(in: collectionView.bounds)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return StickerFlowLayout.minimumLineSpacing(in: collectionView.bounds)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return StickerFlowLayout.minimumLineSpacing(in: collectionView.bounds)
    }
}
