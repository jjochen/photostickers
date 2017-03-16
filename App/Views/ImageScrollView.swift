//
//  ImageScrollView.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

struct ImageWithVisibleRect {
    let image: UIImage?
    let visibleRect: CGRect
}

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

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.addSubview(imageView)
        return imageView
    }()

    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set(image) {
            self.setImage(image)
        }
    }

    var cropRect: CGRect?

    var visibleRect: CGRect {
        get {
            let visibleRect = self.convert(self.cropBounds, to: self.imageView)
            return visibleRect.intersection(self.imageView.bounds)
        }
        set(visibleRect) {
            self.setZoomScale(for: visibleRect)
            self.setContentOffset(for: visibleRect)
        }
    }

    func setImage(_ image: UIImage?, visibleRect: CGRect = .zero) {
        self.imageView.image = image
        self.imageView.frame = CGRect(origin: .zero, size: self.imageSize)
        self.configure(for: visibleRect)
    }

    var imageWithVisibleRect: ImageWithVisibleRect {
        get {
            return ImageWithVisibleRect(image: self.image, visibleRect: self.visibleRect)
        }
        set(imageWithVisibleRect) {
            self.setImage(imageWithVisibleRect.image, visibleRect: imageWithVisibleRect.visibleRect)
        }
    }

    var minimumZoomedImageSize: CGSize?
}

// MARK: - Helper
extension ImageScrollView {
    fileprivate var imageSize: CGSize {
        return self.image?.size ?? .zero
    }

    fileprivate var cropBounds: CGRect {
        guard let cropRect = self.cropRect else {
            return self.bounds
        }
        let cropBounds = cropRect
            .offsetBy(dx: self.bounds.minX, dy: self.bounds.minY)
            .intersection(self.bounds)
        return cropBounds
    }

    fileprivate var _minimumZoomedImageSize: CGSize {
        return self.minimumZoomedImageSize ?? self.cropBounds.size
    }
}

// MARK: - UIScrollView configuration
extension ImageScrollView {
    fileprivate func configure(for visibleRect: CGRect) {
        self.zoomScale = 1 // needed because of some weird scroll view behavior
        self.contentOffset = .zero
        self.contentSize = self.imageSize

        self.configureContentInset()
        self.configureMaxMinZoomScales()
        self.visibleRect = visibleRect
    }

    fileprivate func configureContentInset() {
        guard let cropRect = self.cropRect else {
            self.contentInset = .zero
            return
        }
        var insets = UIEdgeInsets()
        insets.left = cropRect.minX
        insets.top = cropRect.minY
        insets.right = self.bounds.size.width - cropRect.maxX
        insets.bottom = self.bounds.height - cropRect.maxY

        self.contentInset = insets
    }

    fileprivate func configureMaxMinZoomScales() {
        let minScale = self.minScale
        let maxScale = self.maxScale

        self.maximumZoomScale = max(minScale, maxScale)
        self.minimumZoomScale = min(minScale, maxScale)
    }

    fileprivate func setZoomScale(for visibleRect: CGRect) {
        guard visibleRect.width > 0 && visibleRect.height > 0 else {
            self.zoomScale = self.initialZoomScale
            return
        }

        let boundsSize = self.cropBounds.size

        let xScale = boundsSize.width / visibleRect.width
        let yScale = boundsSize.height / visibleRect.height
        var scale = min(xScale, yScale)
        scale = max(scale, self.minScale)
        scale = min(scale, self.maxScale)

        self.zoomScale = scale
    }

    fileprivate func setContentOffset(for visibleRect: CGRect) {
        let visibleRect = visibleRect.isEmpty ? self.initialVisibleRect : visibleRect
        let scale = self.zoomScale
        let cropRectOrigin = self.cropRect?.origin ?? .zero

        var contentOffset = CGPoint()
        contentOffset.x = visibleRect.minX * scale - cropRectOrigin.x
        contentOffset.y = visibleRect.minY * scale - cropRectOrigin.y

        self.contentOffset = contentOffset
    }

    fileprivate var initialZoomScale: CGFloat {
        return self.minScale
    }

    fileprivate var initialVisibleRect: CGRect {
        let imageSize = self.imageSize
        let minSideLength = min(imageSize.width, imageSize.height)

        var visibleRect = CGRect()
        visibleRect.size = imageSize
        visibleRect.origin.x = (imageSize.width - minSideLength) / 2.0
        visibleRect.origin.y = (imageSize.height - minSideLength) / 2.0

        return visibleRect
    }

    fileprivate var minScale: CGFloat {
        let boundsSize = self.cropBounds.size
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
        let boundsSize = self.cropBounds.size
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
