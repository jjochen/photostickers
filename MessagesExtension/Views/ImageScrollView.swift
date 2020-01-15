//
//  ImageScrollView.swift
//  MessagesExtension
//
//  Created by Jochen on 13.01.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//

import UIKit

protocol ImageScrollViewDelegate: AnyObject {
    func imageScrollView(_ imageScrollView: ImageScrollView, didChangeVisibleRect rect: CGRect)
}

class ImageScrollView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    weak var delegate: ImageScrollViewDelegate?

    var minimumZoomSize = CGSize(width: 300, height: 300)

    var image: UIImage? {
        get {
            return imageView.image
        }
        set(image) {
            scrollView.zoomScale = 1
            scrollView.contentOffset = .zero
            imageView.image = image
            scrollView.contentSize = imageSize
            configureZoomScaleLimits()
        }
    }

    var visibleRect: CGRect {
        get {
            return scrollView.convertBounds(to: imageView)
        }
        set(rect) {
            visibleRectCache = rect
            scrollView.zoomScale = zoomScale(forVisibleRect: rect)
            scrollView.contentOffset = contentOffset(forVisibleRect: rect)
        }
    }

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.decelerationRate = .normal
        scrollView.delegate = self

        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        return scrollView
    }()

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit

        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        return imageView
    }()

    fileprivate var previousScrollViewSize = CGSize.zero
    fileprivate var visibleRectCache = CGRect.zero {
        didSet {
            if oldValue == visibleRectCache {
                return
            }
            delegate?.imageScrollView(self, didChangeVisibleRect: visibleRectCache)
        }
    }
}

extension ImageScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if previousScrollViewSize != scrollView.bounds.size {
            configureZoomScaleLimits()
            resetVisibleRect()
        }
        previousScrollViewSize = scrollView.bounds.size
    }
}

// MARK: - UIScrollViewDelegate

extension ImageScrollView: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_: UIScrollView) {
        cacheVisibleRect()
    }

    func scrollViewDidScroll(_: UIScrollView) {
        cacheVisibleRect()
    }
}

private extension ImageScrollView {
    func commonInit() {
        backgroundColor = .clear
        clipsToBounds = false
    }
}

private extension ImageScrollView {
    func resetVisibleRect() {
        guard image != nil else {
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
        scrollView.minimumZoomScale = minimumZoomScaleForCurrentImage
        scrollView.maximumZoomScale = maximumZoomScaleForCurrentImage
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

        let xScale = scrollView.bounds.width / minimumSize.width
        let yScale = scrollView.bounds.height / minimumSize.height
        let maxScale = min(xScale, yScale)
        return maxScale
    }

    var minimumZoomScaleForCurrentImage: CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return 1
        }

        let xScale = scrollView.bounds.width / imageSize.width
        let yScale = scrollView.bounds.height / imageSize.height
        let minScale = max(xScale, yScale)
        return minScale
    }

    func zoomScale(forVisibleRect rect: CGRect) -> CGFloat {
        guard rect.width > 0, rect.height > 0 else {
            return 1
        }

        let xScale = scrollView.bounds.width / rect.width
        let yScale = scrollView.bounds.height / rect.height
        let zoomScale = min(xScale, yScale)
        return zoomScale
    }

    func contentOffset(forVisibleRect rect: CGRect) -> CGPoint {
        let scale = zoomScale(forVisibleRect: rect)
        var offset = rect.origin
        offset.x *= scale
        offset.y *= scale
        return offset
    }
}
