//
//  ImageScrollView.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    fileprivate func setup() {
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.scrollsToTop = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
    }

    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set(image) {
            self.imageView.image = image
            self.imageView.frame = CGRect(origin: .zero, size: self.imageSize)
            self.configure()
        }
    }

    var visibleRect: CGRect {
        let visibleRect = self.convert(self.bounds, to: self.imageView)
        return visibleRect.intersection(self.imageView.bounds)
    }

    var minimumZoomedImageSize: CGSize?

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.addSubview(imageView)
        return imageView
    }()
}

// MARK: - Helper
extension ImageScrollView {

    fileprivate var imageSize: CGSize {
        return self.image?.size ?? .zero
    }

    fileprivate var _minimumZoomedImageSize: CGSize {
        return self.minimumZoomedImageSize ?? self.bounds.size // check: multiply by image scale?
    }
}

// MARK: - UIScrollView configuration
extension ImageScrollView {

    fileprivate func configure() {
        self.zoomScale = 1 // needed because of weird behavior
        self.contentSize = self.imageSize

        self.setMaxMinZoomScalesForCurrentBounds()
        self.setInitialZoomScale()
        self.setInitialContentOffset()
    }

    fileprivate func setMaxMinZoomScalesForCurrentBounds() {
        let minScale = self.minScale
        let maxScale = self.maxScale

        self.maximumZoomScale = max(minScale, maxScale)
        self.minimumZoomScale = min(minScale, maxScale)
    }

    fileprivate func setInitialZoomScale() {
        self.zoomScale = self.minScale
    }

    fileprivate func setInitialContentOffset() {

        let boundsSize = self.bounds.size
        let imageSize = self.imageSize
        let scale = self.minScale
        let scaledImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)

        var contentOffset = CGPoint()
        contentOffset.x = max(0, (scaledImageSize.width - boundsSize.width) * 0.5)
        contentOffset.y = max(0, (scaledImageSize.height - boundsSize.height) * 0.5)

        self.contentOffset = contentOffset
    }

    fileprivate var minScale: CGFloat {

        let boundsSize = self.bounds.size
        let imageSize = self.imageSize

        guard imageSize.width > 0 && imageSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = max(xScale, yScale)
        return minScale
    }

    fileprivate var maxScale: CGFloat {

        let boundsSize = self.bounds.size
        let minimumZoomedImageSize = self._minimumZoomedImageSize

        guard minimumZoomedImageSize.width > 0 && minimumZoomedImageSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / minimumZoomedImageSize.width
        let yScale = boundsSize.height / minimumZoomedImageSize.height
        let maxScale = min(xScale, yScale)
        return maxScale
    }
}

// MARK: - UIScrollViewDelegate
extension ImageScrollView {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
