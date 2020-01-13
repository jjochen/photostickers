//
//  ImageScrollView.swift
//  MessagesExtension
//
//  Created by Jochen on 13.01.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    var minimumZoomSize = CGSize(width: 300, height: 300)

    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set(image) {
            zoomScale = 1
            contentOffset = .zero
            imageView.image = image
            contentSize = image?.size ?? .zero
            configureZoomScaleLimits()
        }
    }

    var visibleRect: CGRect {
        get {
            return convertBounds(to: imageView)
        }
        set(rect) {
            visibleRectCache = rect
            zoomScale = zoomScale(forVisibleRect: rect)
            contentOffset = contentOffset(forVisibleRect: rect)
        }
    }

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        return imageView
    }()

    fileprivate var previousFrame = CGRect.null
    fileprivate var visibleRectCache = CGRect.null {
        didSet {
            if oldValue == visibleRectCache {
                return
            }
            
        }
    }
}

extension ImageScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()
        configureZoomScaleLimits()
        resetVisibleRect()
        previousFrame = frame
    }
}

// MARK: - UIScrollViewDelegate

extension ImageScrollView: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        cacheVisibleRect()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cacheVisibleRect()
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        cacheVisibleRect()
    }
}

private extension ImageScrollView {
    func commonInit() {
        clipsToBounds = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        delegate = self
    }
}

private extension ImageScrollView {
    func resetVisibleRect() {
        guard image != nil, previousFrame != frame else {
            return
        }

        visibleRect = visibleRectCache
    }

    func cacheVisibleRect() {
        guard image != nil else {
            return
        }

        visibleRectCache = visibleRect
    }

    func configureZoomScaleLimits() {
        self.minimumZoomScale = minimumZoomScaleForCurrentImage
        self.maximumZoomScale = maximumZoomScaleForCurrentImage
    }

    var imageSize: CGSize {
        return image?.size ?? .zero
    }

    var minimumZoomSizeForCurrentImage: CGSize {
        let minSideLength = imageSize.minSideLength
        var minimumZoomedSize = CGSize()
        minimumZoomedSize.width = min(minSideLength, minimumZoomSize.width)
        minimumZoomedSize.height = min(minSideLength, minimumZoomSize.height)
        return minimumZoomedSize
    }

    var maximumZoomScaleForCurrentImage: CGFloat {
        let minimumSize = minimumZoomSizeForCurrentImage
        guard minimumSize.width > 0, minimumSize.height > 0 else {
            return 1
        }

        let xScale = bounds.width / minimumSize.width
        let yScale = bounds.height / minimumSize.height
        let maxScale = min(xScale, yScale)
        return maxScale
    }

    var minimumZoomScaleForCurrentImage: CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return 1
        }

        let xScale = bounds.width / imageSize.width
        let yScale = bounds.height / imageSize.height
        let minScale = max(xScale, yScale)
        return minScale
    }

    func zoomScale(forVisibleRect rect: CGRect) -> CGFloat {
        guard rect.width > 0, rect.height > 0 else {
            return 1
        }

        let xScale = bounds.width / rect.width
        let yScale = bounds.height / rect.height
        let zoomScale = min(xScale, yScale)
        return zoomScale
    }

    func contentOffset(forVisibleRect rect: CGRect) -> CGPoint {
        let scale = zoomScale(forVisibleRect: rect)
        var offset = visibleRect.origin
        offset.x *= scale
        offset.y *= scale
        return offset
    }
}
