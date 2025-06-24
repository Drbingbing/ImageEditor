//
//  UIImage+.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/16.
//

import UIKit

extension UIImage {
    
    var pixelWidth: Int {
        switch imageOrientation {
        case .up, .down, .upMirrored, .downMirrored:
            return cgImage?.width ?? 0
        case .left, .right, .leftMirrored, .rightMirrored:
            return cgImage?.height ?? 0
        @unknown default:
            debugPrint("unhandled image orientation: \(imageOrientation)")
            return 0
        }
    }
    
    var pixelHeight: Int {
        switch imageOrientation {
        case .up, .down, .upMirrored, .downMirrored:
            return cgImage?.height ?? 0
        case .left, .right, .leftMirrored, .rightMirrored:
            return cgImage?.width ?? 0
        @unknown default:
            debugPrint("unhandled image orientation: \(imageOrientation)")
            return 0
        }
    }
    
    var pixelSize: CGSize {
        CGSize(width: pixelWidth, height: pixelHeight)
    }
    
    func normalized() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        }
    }

    func cgImageWithGaussianBlurAsync(radius: CGFloat, resizeToMaxPixelDimension: CGFloat) async throws -> CGImage {
        try await withCheckedThrowingContinuation { continuation in
            Task(priority: .userInitiated) {
                guard let resizeImage = self.resized(maxDimensionPixels: resizeToMaxPixelDimension) else {
                    throw IEAssertionError("Failed to downsize image for blur")
                }
                
                let image = try resizeImage.cgImageWithGaussianBlur(radius: radius)
                continuation.resume(returning: image)
            }
        }
    }
    
    func cgImageWithGaussianBlur(radius: CGFloat, tintColor: UIColor? = nil) throws -> CGImage {
        guard let clampFilter = CIFilter(name: "CIAffineClamp") else {
            throw IEAssertionError("Failed to create blur filter")
        }

        guard let blurFilter = CIFilter(name: "CIGaussianBlur",
                                        parameters: [kCIInputRadiusKey: radius]) else {
            throw IEAssertionError("Failed to create blur filter")
        }
        guard let cgImage = self.cgImage else {
            throw IEAssertionError("Missing cgImage.")
        }

        // In order to get a nice edge-to-edge blur, we must apply a clamp filter and *then* the blur filter.
        let inputImage = CIImage(cgImage: cgImage)
        clampFilter.setDefaults()
        clampFilter.setValue(inputImage, forKey: kCIInputImageKey)

        guard let clampOutput = clampFilter.outputImage else {
            throw IEAssertionError("Failed to clamp image")
        }

        blurFilter.setValue(clampOutput, forKey: kCIInputImageKey)

        guard let blurredOutput = blurFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            throw IEAssertionError("Failed to blur clamped image")
        }

        var outputImage: CIImage = blurredOutput
        if let tintColor = tintColor {
            guard let tintFilter = CIFilter(name: "CIConstantColorGenerator",
                                            parameters: [
                                                kCIInputColorKey: CIColor(color: tintColor)
                                            ]) else {
                throw IEAssertionError("Could not create tintFilter.")
            }
            guard let tintImage = tintFilter.outputImage else {
                throw IEAssertionError("Could not create tintImage.")
            }

            guard let tintOverlayFilter = CIFilter(name: "CISourceOverCompositing",
                                                   parameters: [
                                                    kCIInputBackgroundImageKey: outputImage,
                                                    kCIInputImageKey: tintImage
                                                   ]) else {
                throw IEAssertionError("Could not create tintOverlayFilter.")
            }
            guard let tintOverlayImage = tintOverlayFilter.outputImage else {
                throw IEAssertionError("Could not create tintOverlayImage.")
            }
            outputImage = tintOverlayImage
        }

        let context = CIContext(options: nil)
        guard let blurredImage = context.createCGImage(outputImage, from: inputImage.extent) else {
            throw IEAssertionError("Failed to create CGImage from blurred output")
        }

        return blurredImage
    }
    
    func resized(maxDimensionPixels: CGFloat) -> UIImage? {
        resized(originalSize: pixelSize, maxDimension: maxDimensionPixels, isPixels: true)
    }
    
    private func resized(originalSize: CGSize, maxDimension: CGFloat, isPixels: Bool) -> UIImage? {
        if originalSize.width < 1 || originalSize.height < 1 {
            debugPrint("Invalid original size: \(originalSize)")
            return nil
        }

        let maxOriginalDimension = max(originalSize.width, originalSize.height)
        if maxOriginalDimension < maxDimension {
            // Don't bother scaling an image that is already smaller than the max dimension.
            return self
        }

        var unroundedThumbnailSize: CGSize
        if originalSize.width > originalSize.height {
            unroundedThumbnailSize = CGSize(width: maxDimension, height: maxDimension * originalSize.height / originalSize.width)
        } else {
            unroundedThumbnailSize = CGSize(width: maxDimension * originalSize.width / originalSize.height, height: maxDimension)
        }

        var renderRect = CGRect(origin: .zero,
                                size: CGSize.init(width: round(unroundedThumbnailSize.width),
                                                  height: round(unroundedThumbnailSize.height)))
        if unroundedThumbnailSize.width < 1 {
            // crop instead of resizing.
            let newWidth = min(maxDimension, originalSize.width)
            let newHeight = originalSize.height * (newWidth / originalSize.width)
            renderRect.origin.y = round((maxDimension - newHeight) / 2)
            renderRect.size.width = round(newWidth)
            renderRect.size.height = round(newHeight)
            unroundedThumbnailSize.height = maxDimension
            unroundedThumbnailSize.width = newWidth
        }
        if unroundedThumbnailSize.height < 1 {
            // crop instead of resizing.
            let newHeight = min(maxDimension, originalSize.height)
            let newWidth = originalSize.width * (newHeight / originalSize.height)
            renderRect.origin.x = round((maxDimension - newWidth) / 2)
            renderRect.size.width = round(newWidth)
            renderRect.size.height = round(newHeight)
            unroundedThumbnailSize.height = newHeight
            unroundedThumbnailSize.width = maxDimension
        }

        let thumbnailSize = CGSize(width: round(unroundedThumbnailSize.width),
                                   height: round(unroundedThumbnailSize.height))

        let format = UIGraphicsImageRendererFormat()
        if isPixels {
            format.scale = 1
        }
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize, format: format)
        return renderer.image { context in
            context.cgContext.interpolationQuality = .high
            draw(in: renderRect)
        }
    }
}
