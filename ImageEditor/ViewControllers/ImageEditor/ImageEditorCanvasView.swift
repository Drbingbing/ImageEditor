//
//  ImageEditorCanvasView.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/13.
//

import UIKit

final class ImageEditorCanvasView: UIView {
    
    private let model: ImageEditorModel
    
    let contentView = DynamicLayoutView()
    
    // clipView is used to clip the content.  It reflects the actual
    // visible bounds of the "canvas" content.
    private let clipView = DynamicLayoutView()
    
    private var contentViewConstraints = [NSLayoutConstraint]()

    private var imageLayer = CALayer()
    
    /// We want blurs to be rendered above the image and behind strokes and text.
    private static let blurLayerZ: CGFloat = +1
    /// We want strokes to be rendered above the image and blurs and behind text.
    private static let brushLayerZ: CGFloat = +2
    /// We want text to be rendered above the image, blurs, and strokes.
    private static let textLayerZ: CGFloat = +3
    /// Selection frame is rendered above all content.
    private static let selectionFrameLayerZ: CGFloat = +4
    /// Trash is rendered above all content.
    static let trashLazerZ: CGFloat = +5
    /// We leave space for 10k items/layers of each type.
    private static let zPositionSpacing: CGFloat = 0.0001
    
    init(model: ImageEditorModel) {
        self.model = model
        super.init(frame: .zero)
        
        model.addObserver(observer: self)
        
        prepareBlurredImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        
        backgroundColor = .clear
        isOpaque = true
        
        clipView.clipsToBounds = true
        clipView.isOpaque = false
        clipView.layoutCallback = { [weak self] _ in
            self?.updateLayout()
        }
        addSubview(clipView)
        
        if let srcImage = self.loadSrcImage() {
            imageLayer.contents = srcImage.cgImage
            imageLayer.contentsScale = srcImage.scale
        }

        contentView.isOpaque = false
        contentView.layer.addSublayer(imageLayer)
        contentView.layoutCallback = { [weak self] _ in
            self?.updateAllContent()
        }
        clipView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        
        updateLayout()
    }
    
    var gestureReferenceView: UIView {
        return clipView
    }
    
    private func updateLayout() {
        NSLayoutConstraint.deactivate(contentViewConstraints)
        contentViewConstraints = Self.updateContentLayout(transform: model.currentTransform(), contentView: clipView)
    }

    // MARK: - Content

    private var contentLayerMap = [String: CALayer]()
    
    private func updateAllContent() {
        // Don't animate changes.
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        for layer in contentLayerMap.values {
            layer.removeFromSuperlayer()
        }
        contentLayerMap.removeAll()
        
        let viewSize = clipView.bounds.size
        let transform = model.currentTransform()
        if viewSize.width > 0, viewSize.height > 0 {
            
            applyTransform()
            updateImageLayer()
            
            for item in model.items() {
                guard let layer = Self.layerForItem(item: item,
                                                    model: model,
                                                    shouldFadeTransformableItemWithID: nil,
                                                    transform: transform,
                                                    viewSize: viewSize) else {
                    continue
                }
                
                contentView.layer.addSublayer(layer)
                contentLayerMap[item.itemId] = layer
            }
        }
        
        updateLayout()
        
        setNeedsLayout()
        layoutIfNeeded()
        
        CATransaction.commit()
    }
    
    private func updateContent(changedItemIds: [String]) {
        
        // Don't animate changes.
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // Remove all changed items.
        for itemId in changedItemIds {
            if let layer = contentLayerMap[itemId] {
                layer.removeFromSuperlayer()
            }
            contentLayerMap.removeValue(forKey: itemId)
        }

        let viewSize = clipView.bounds.size
        let transform = model.currentTransform()
        if viewSize.width > 0,
            viewSize.height > 0 {

            applyTransform()

            updateImageLayer()

            // Create layers for inserted and updated items.
            for itemId in changedItemIds {
                guard let item = model.item(forId: itemId) else {
                    // Item was deleted.
                    continue
                }

                // Item was inserted or updated.
                guard let layer = ImageEditorCanvasView.layerForItem(
                    item: item,
                    model: model,
                    shouldFadeTransformableItemWithID: nil,
                    transform: transform,
                    viewSize: viewSize
                ) else {
                    continue
                }

                contentView.layer.addSublayer(layer)
                contentLayerMap[item.itemId] = layer
            }
        }

        CATransaction.commit()
    }
    
    private func applyTransform() {
        let viewSize = clipView.bounds.size
        contentView.layer.setAffineTransform(model.currentTransform().affineTransform(viewSize: viewSize))
    }
    
    private func updateImageLayer() {
        let viewSize = clipView.bounds.size
        Self.updateImageLayer(imageLayer: imageLayer, viewSize: viewSize, imageSize: model.srcImageSizePixels, transform: model.currentTransform())
    }
    
    class func updateContentLayout(transform: ImageEditorTransform, contentView: UIView) -> [NSLayoutConstraint] {
        guard let superview = contentView.superview else {
            debugPrint("Content view has no superview.")
            return []
        }
        
        let aspectRatio = transform.outputSizePixels
        
        // This emulates the behavior of contentMode = .scaleAspectFit using iOS auto layout constraints.
        var constraints = [NSLayoutConstraint]()
        NSLayoutConstraint.autoSetPriority(.defaultHigh + 100) {
            constraints.append(contentView.autoAlignAxis(.vertical, toSameAxisOf: superview))
            constraints.append(contentView.autoAlignAxis(.horizontal, toSameAxisOf: superview))
        }
        constraints.append(contentView.autoPinEdge(.top, to: .top, of: superview, withOffset: 0, relation: .greaterThanOrEqual))
        constraints.append(contentView.autoPinEdge(.bottom, to: .bottom, of: superview, withOffset: 0, relation: .lessThanOrEqual))
        constraints.append(contentView.autoPin(toAspectRatio: aspectRatio.width / aspectRatio.height))
        constraints.append(contentView.autoMatch(.width, to: .width, of: superview, withMultiplier: 1.0, relation: .lessThanOrEqual))
        constraints.append(contentView.autoMatch(.height, to: .height, of: superview, withMultiplier: 1.0, relation: .lessThanOrEqual))
        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            constraints.append(contentView.autoMatch(.width, to: .width, of: superview, withMultiplier: 1.0, relation: .equal))
            constraints.append(contentView.autoMatch(.height, to: .height, of: superview, withMultiplier: 1.0, relation: .equal))
        }

        let superviewSize = superview.frame.size
        let maxSuperviewDimension = max(superviewSize.width, superviewSize.height)
        let outputSizePoints = CGSize(square: maxSuperviewDimension)
        NSLayoutConstraint.autoSetPriority(.defaultLow) {
            constraints.append(contentsOf: contentView.autoSetDimensions(to: outputSizePoints))
        }
        return constraints
    }
    
    private func loadSrcImage() -> UIImage? {
        return ImageEditorCanvasView.loadSrcImage(model: model)
    }
    
    class func loadSrcImage(model: ImageEditorModel) -> UIImage? {
        model.srcImage.normalized()
    }
    
    class func updateImageLayer(imageLayer: CALayer, viewSize: CGSize, imageSize: CGSize, transform: ImageEditorTransform) {
        imageLayer.frame = imageFrame(forViewSize: viewSize, imageSize: imageSize, transform: transform)

        // This is the only place the isFlipped flag is consulted.
        // We deliberately do _not_ use it in the affine transforms, etc.
        // so that:
        //
        // * It doesn't affect text content & brush strokes.
        // * To not complicate the other "coordinate system math".
        let transform = CGAffineTransform.identity.scaledBy(x: transform.isFlipped ? -1 : +1, y: 1)
        imageLayer.setAffineTransform(transform)
    }
    
    class func imageFrame(forViewSize viewSize: CGSize, imageSize: CGSize, transform: ImageEditorTransform) -> CGRect {
        guard viewSize.width > 0, viewSize.height > 0 else {
            debugPrint("Invalid viewSize")
            return .zero
        }
        guard imageSize.width > 0, imageSize.height > 0 else {
            debugPrint("Invalid imageSize")
            return .zero
        }
        
        let sinValue = abs(sin(transform.rotationRadians))
        let cosValue = abs(cos(transform.rotationRadians))
        let outputSize = CGSize(width: viewSize.width * cosValue + viewSize.height * sinValue,
                                height: viewSize.width * sinValue + viewSize.height * cosValue)

        var width = outputSize.width
        var height = outputSize.width * imageSize.height / imageSize.width
        if height < outputSize.height {
            width = outputSize.height * imageSize.width / imageSize.height
            height = outputSize.height
        }
        
        let imageFrame = CGRect(x: (width - viewSize.width) * -0.5,
                                y: (height - viewSize.height) * -0.5,
                                width: width,
                                height: height)

        return imageFrame
    }
    
    private class func layerForItem(
        item: ImageEditorItem,
        model: ImageEditorModel,
        shouldFadeTransformableItemWithID fadedItemID: String?,
        transform: ImageEditorTransform,
        viewSize: CGSize
    ) -> CALayer? {
        assertIsOnMainThread()
        
        switch item.itemType {
        case .stroke:
            guard let strokeItem = item as? ImageEditorStrokeItem else {
                ieFailDebug("Item has unexpected type: \(type(of: item))")
                return nil
            }
            
            return strokeLayerForItem(item: strokeItem, model: model, transform: transform, viewSize: viewSize)
        }
    }
    
    private class func strokeLayerForItem(item: ImageEditorStrokeItem, model: ImageEditorModel, transform: ImageEditorTransform, viewSize: CGSize) -> CALayer? {
        assertIsOnMainThread()
        
        let optionalBlurredImageLayer: CALayer?
        
        let blurredImageLayer = blurredImageLayerForItem(model: model, transform: transform, viewSize: viewSize)
        
        blurredImageLayer?.zPosition = zPositionForItem(item: item, model: model, zPositionBase: blurLayerZ)
        optionalBlurredImageLayer = blurredImageLayer
        
        let strokeWidth = item.strokeWidth(forDstSize: viewSize)
        let unitSamples = item.unitSamples
        guard unitSamples.count > 0 else {
            return nil
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = strokeWidth
        shapeLayer.strokeColor = item.color?.cgColor
        shapeLayer.frame = CGRect(origin: .zero, size: viewSize)

        // Blur region origins are specified in "image unit" coordinates,
        // but need to be rendered in "canvas" coordinates. The imageFrame
        // is the bounds of the image specified in "canvas" coordinates,
        // so to transform we can simply convert from image frame units.
        let imageFrame = ImageEditorCanvasView.imageFrame(forViewSize: viewSize, imageSize: model.srcImageSizePixels, transform: transform)
        let transformSampleToPoint = { (unitSample: CGPoint) -> CGPoint in
            return unitSample.fromUnitCoordinates(viewBounds: imageFrame)
        }

        // Use bezier curves to smooth stroke.
        let bezierPath = UIBezierPath()

        let points = applySmoothing(to: unitSamples.map { (unitSample) in
            transformSampleToPoint(unitSample)
        })
        var previousForwardVector = CGPoint.zero
        for index in 0..<points.count {
            let point = points[index]

            let forwardVector: CGPoint
            if points.count <= 1 {
                // Skip forward vectors.
                forwardVector = .zero
            } else if index == 0 {
                // First sample.
                let nextPoint = points[index + 1]
                forwardVector = CGPoint.subtract(nextPoint, point)
            } else if index == points.count - 1 {
                // Last sample.
                let previousPoint = points[index - 1]
                forwardVector = CGPoint.subtract(point, previousPoint)
            } else {
                // Middle samples.
                let previousPoint = points[index - 1]
                let previousPointForwardVector = CGPoint.subtract(point, previousPoint)
                let nextPoint = points[index + 1]
                let nextPointForwardVector = CGPoint.subtract(nextPoint, point)
                forwardVector = CGPoint.scale(CGPoint.add(previousPointForwardVector, nextPointForwardVector), factor: 0.5)
            }

            if index == 0 {
                // First sample.
                bezierPath.move(to: point)

                if points.count == 1 {
                    bezierPath.addLine(to: point)
                }
            } else {
                let previousPoint = points[index - 1]
                // We apply more than one kind of smoothing.
                // This smoothing avoids rendering "angled segments"
                // by drawing the stroke as a series of curves.
                // We use bezier curves and infer the control points
                // from the "next" and "prev" points.
                //
                // This factor controls how much we're smoothing.
                //
                // * 0.0 = No smoothing.
                //
                // TODO: Tune this variable once we have stroke input.
                let controlPointFactor: CGFloat = 0.25
                let controlPoint1 = CGPoint.add(previousPoint, CGPoint.scale(previousForwardVector, factor: +controlPointFactor))
                let controlPoint2 = CGPoint.add(point, CGPoint.scale(forwardVector, factor: -controlPointFactor))
                // We're using Cubic curves.
                bezierPath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
            previousForwardVector = forwardVector
        }

        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = nil

        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round

        if item.strokeType == .blur {
            guard let blurredImageLayer = optionalBlurredImageLayer else {
                debugPrint("Unexpectedly missing blurredImageLayer")
                return nil
            }

            shapeLayer.strokeColor = UIColor.black.cgColor
            blurredImageLayer.mask = shapeLayer

            return blurredImageLayer
        } else {
            shapeLayer.zPosition = zPositionForItem(item: item, model: model, zPositionBase: brushLayerZ)

            return shapeLayer
        }
    }
    
    private class func applySmoothing(to points: [CGPoint]) -> [CGPoint] {
        
        var result = [CGPoint]()

        for index in 0..<points.count {
            let point = points[index]

            if index == 0 {
                // First sample.
                result.append(point)
            } else if index == points.count - 1 {
                // Last sample.
                result.append(point)
            } else {
                // Middle samples.
                let lastPoint = points[index - 1]
                let nextPoint = points[index + 1]
                let alpha: CGFloat = 0.1
                let smoothedPoint = CGPoint.add(CGPoint.scale(point, factor: 1.0 - 2.0 * alpha),
                                                CGPoint.add(CGPoint.scale(lastPoint, factor: alpha),
                                                            CGPoint.scale(nextPoint, factor: alpha)))
                result.append(smoothedPoint)
            }
        }

        return result
    }
    
    private func prepareBlurredImage() {
        guard let srcImage = loadSrcImage() else {
            return ieFailDebug("Could not load src image.")
        }

        // we use a very strong blur radius to ensure adequate coverage of large and small faces
        Task { @MainActor in
            let image = try await srcImage.cgImageWithGaussianBlurAsync(radius: 25, resizeToMaxPixelDimension: 300)
            self.model.blurredSourceImage = image
            if self.window != nil {
                self.updateAllContent()
            }
        }
    }
    
    private class func blurredImageLayerForItem(model: ImageEditorModel,
                                                transform: ImageEditorTransform,
                                                viewSize: CGSize) -> CALayer? {
        guard let blurredSourceImage = model.blurredSourceImage else {
            // If we fail to generate the blur image, or it's not ready yet, use a black mask
            let layer = CALayer()
            layer.frame = imageFrame(forViewSize: viewSize, imageSize: model.srcImageSizePixels, transform: transform)
            layer.backgroundColor = UIColor.black.cgColor
            return layer
        }

        // The image layer renders the blurred image in canvas coordinates
        let blurredImageLayer = CALayer()
        blurredImageLayer.contents = blurredSourceImage
        updateImageLayer(imageLayer: blurredImageLayer,
                         viewSize: viewSize,
                         imageSize: model.srcImageSizePixels,
                         transform: transform)

        // The container holds the blurred image, and can be masked using canvas
        // coordinates to partially blur the image.
        let blurredImageContainer = CALayer()
        blurredImageContainer.addSublayer(blurredImageLayer)
        blurredImageContainer.frame = CGRect(origin: .zero, size: viewSize)

        return blurredImageContainer
    }
    
    private class func zPositionForItem(item: ImageEditorItem,
                                        model: ImageEditorModel,
                                        zPositionBase: CGFloat) -> CGFloat {
        let itemIds = model.itemIds()
        guard let itemIndex = itemIds.firstIndex(of: item.itemId) else {
            ieFailDebug("Couldn't find index of item.")
            return zPositionBase
        }
        return zPositionBase + CGFloat(itemIndex) * zPositionSpacing
    }
    
    // MARK: - Coordinates
    
    class func locationImageUnit(forLocationInView locationInView: CGPoint,
                                 viewBounds: CGRect,
                                 model: ImageEditorModel,
                                 transform: ImageEditorTransform) -> CGPoint {
        let imageFrame = self.imageFrame(forViewSize: viewBounds.size, imageSize: model.srcImageSizePixels, transform: transform)
        let affineTransformStart = transform.affineTransform(viewSize: viewBounds.size)
        let locationInContent = locationInView.minus(viewBounds.center).applyingInverse(affineTransformStart).plus(viewBounds.center)
        let locationImageUnit = locationInContent.toUnitCoordinates(viewBounds: imageFrame, shouldClamp: false)
        return locationImageUnit
    }
}

extension ImageEditorCanvasView: ImageEditorModelObserver {
    
    func imageEditorModelDidChange(changedItemIds: [String]) {
        updateContent(changedItemIds: changedItemIds)
    }
    
    func imageEditorModelDidChange(before: ImageEditorContents, after: ImageEditorContents) {
        updateAllContent()
    }
}
