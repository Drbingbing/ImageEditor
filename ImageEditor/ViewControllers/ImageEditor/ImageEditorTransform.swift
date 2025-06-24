//
//  ImageEditorTransform.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/16.
//
import Foundation

struct ImageEditorTransform {
    
    let outputSizePixels: CGSize
    
    let unitTranslation: CGPoint
    
    let rotationRadians: CGFloat
    
    let scaling: CGFloat
    
    let isFlipped: Bool
    
    init(outputSizePixels: CGSize, unitTranslation: CGPoint, rotationRadians: CGFloat, scaling: CGFloat, isFlipped: Bool) {
        self.outputSizePixels = outputSizePixels
        self.unitTranslation = unitTranslation
        self.rotationRadians = rotationRadians
        self.scaling = scaling
        self.isFlipped = isFlipped
    }
    
    func normalize(srcImageSizePixels: CGSize) -> ImageEditorTransform {
        let minScaling: CGFloat = 1
        let scaling = max(minScaling, scaling)
        
        let viewBounds = CGRect(origin: .zero, size: outputSizePixels)
        
        let naiveTransform = ImageEditorTransform(outputSizePixels: outputSizePixels,
                                                  unitTranslation: .zero,
                                                   rotationRadians: rotationRadians,
                                                   scaling: scaling,
                                                   isFlipped: isFlipped)
        
        let naiveAffineTransform = naiveTransform.affineTransform(viewSize: viewBounds.size)
        var naiveViewportMinCanvas = CGPoint.zero
        var naiveViewportMaxCanvas = CGPoint.zero
        var isFirstCorner = true
        
        for viewCorner in [
            viewBounds.topLeft,
            viewBounds.topRight,
            viewBounds.bottomLeft,
            viewBounds.bottomRight
        ] {
            let naiveViewCornerInCanvas = viewCorner.minus(viewBounds.center).applyingInverse(naiveAffineTransform).plus(viewBounds.center)
            if isFirstCorner {
                naiveViewportMinCanvas = naiveViewCornerInCanvas
                naiveViewportMaxCanvas = naiveViewCornerInCanvas
                isFirstCorner = false
            } else {
                naiveViewportMinCanvas = naiveViewportMinCanvas.min(naiveViewCornerInCanvas)
                naiveViewportMaxCanvas = naiveViewportMaxCanvas.max(naiveViewCornerInCanvas)
            }
        }
        
        let naiveViewportSizeCanvas: CGPoint = naiveViewportMaxCanvas.minus(naiveViewportMinCanvas)
        
        let naiveImageFrameCanvas = ImageEditorCanvasView.imageFrame(forViewSize: viewBounds.size, imageSize: srcImageSizePixels, transform: naiveTransform)
        let naiveImageSizeCanvas = CGPoint(x: naiveImageFrameCanvas.width, y: naiveImageFrameCanvas.height)
        
        let maxTranslationCanvas = naiveImageSizeCanvas.minus(naiveViewportSizeCanvas).times(0.5).max(.zero)
        
        let translationInView = unitTranslation.fromUnitCoordinates(viewBounds: viewBounds)
        let translationInCanvas = translationInView.applyingInverse(naiveAffineTransform)
        
        let clampedTranslationInCanvas = translationInCanvas.min(maxTranslationCanvas).max(maxTranslationCanvas.inverse())
        let clampedTranslationInView = clampedTranslationInCanvas.applying(naiveAffineTransform)
        let unitTranslation = clampedTranslationInView.toUnitCoordinates(viewBounds: viewBounds, shouldClamp: false)

        return ImageEditorTransform(outputSizePixels: outputSizePixels,
                                    unitTranslation: unitTranslation,
                                    rotationRadians: rotationRadians,
                                    scaling: scaling,
                                    isFlipped: isFlipped)
    }
    
    func affineTransform(viewSize: CGSize) -> CGAffineTransform {
        let translation = unitTranslation.fromUnitCoordinates(viewSize: viewSize)
        
        let transform = CGAffineTransform.identity
            .translate(translation)
            .rotated(by: rotationRadians)
            .scaledBy(x: scaling, y: scaling)
        
        return transform
    }
}

extension ImageEditorTransform {
    
    static func defaultTransform(srcImageSizePixels: CGSize) -> ImageEditorTransform {
        ImageEditorTransform(
            outputSizePixels: srcImageSizePixels,
            unitTranslation: .zero,
            rotationRadians: 0.0,
            scaling: 1,
            isFlipped: false
        )
    }
}
