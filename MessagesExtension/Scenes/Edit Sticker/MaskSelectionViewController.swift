//
//  MaskSelectionViewController.swift
//  MessagesExtension
//
//  Created by Jochen on 27.12.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Reusable
import RxCocoa
import RxOptional
import RxSwift
import RxViewController
import UIKit

class MaskSelectionViewController: UIViewController, StoryboardBased, ViewModelBased {
    var viewModel: MaskSelectionViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet var circleButton: UIButton!
    @IBOutlet var rectangleButton: UIButton!
    @IBOutlet var starButton: UIButton!
    @IBOutlet var multiStarButton: UIButton!
}

// MASK: - UIViewController override
extension MaskSelectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = StyleKit.appColor
        setupBindings()
    }
}

// MARK: - Bindings

private extension MaskSelectionViewController {
    func setupBindings() {
        guard let viewModel = self.viewModel else {
            fatalError("View Model not set!")
        }

        let circleButtonDidTap = circleButton.rx.tap.asDriver()

        let rectangleButtonDidTap = rectangleButton.rx.tap.asDriver()

        let starButtonDidTap = starButton.rx.tap.asDriver()

        let multiStarButtonDidTap = multiStarButton.rx.tap.asDriver()

        let input = ViewModelType.Input(circleButtonDidTap: circleButtonDidTap,
                                        rectangleButtonDidTap: rectangleButtonDidTap,
                                        starButtonDidTap: starButtonDidTap,
                                        multiStarButtonDidTap: multiStarButtonDidTap)
        let output = viewModel.transform(input: input)
    }
}

private extension MaskSelectionViewController {
    func setupButtons() {
        let lineWidth = CGFloat(3)

        circleButton.setTitle(nil, for: UIControl.State())
        circleButton.titleLabel?.isHidden = true
        circleButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfCircleButton(lineWidth: lineWidth,
                                         selected: selected,
                                         highlighted: highlighted)
        }

        rectangleButton.setTitle(nil, for: UIControl.State())
        rectangleButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfRectangleButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }

        multiStarButton.setTitle(nil, for: UIControl.State())
        multiStarButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfMultiStarButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }

        starButton.setTitle(nil, for: UIControl.State())
        starButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfStarButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }
    }
}
