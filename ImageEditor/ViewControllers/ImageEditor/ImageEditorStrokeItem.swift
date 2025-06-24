//
//  ImageEditorStrokeItem.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/16.
//

import Foundation
import UIKit

class ImageEditorStrokeItem: ImageEditorItem {
    
    enum StrokeType: Equatable {
        case blur
    }
    
    let color: UIColor?
    let strokeType: StrokeType
    let unitStrokeWidth: CGFloat
    
    typealias StrokeSample = ImageEditorSample
    
    let unitSamples: [StrokeSample]
    
    init(color: UIColor? = nil,
         strokeType: StrokeType,
         unitSamples: [StrokeSample],
         unitStrokeWidth: CGFloat) {
        self.strokeType = strokeType
        self.unitStrokeWidth = unitStrokeWidth
        self.unitSamples = unitSamples
        self.color = color
        super.init(itemType: .stroke)
    }
    
    init(itemId: String,
         color: UIColor? = nil,
         strokeType: StrokeType,
         unitSamples: [StrokeSample],
         unitStrokeWidth: CGFloat) {
        self.color = color
        self.strokeType = strokeType
        self.unitSamples = unitSamples
        self.unitStrokeWidth = unitStrokeWidth
        
        super.init(itemId: itemId, itemType: .stroke)
    }
    
    func strokeWidth(forDstSize dstSize: CGSize) -> CGFloat {
        ImageEditorStrokeItem.strokeWidth(forUnitStrokeWidth: unitStrokeWidth, dstSize: dstSize)
    }
    
    private class func metrics(forStrokeType strokeType: StrokeType) -> (CGFloat, CGFloat) {
        switch strokeType {
        case .blur:
            return (0.05, 2)
        }
    }
    
    class func unitStrokeWidth(forStrokeType strokeType: StrokeType,
                               widthAdjustmentFactor adjustmentFactor: CGFloat) -> CGFloat {
        let (defaultWidth, power) = metrics(forStrokeType: strokeType)
        let multiplier: CGFloat
        if adjustmentFactor > 1 {
            multiplier = pow(adjustmentFactor, power)
        } else {
            multiplier = adjustmentFactor
        }
        return defaultWidth * multiplier
    }

    class func strokeWidth(forUnitStrokeWidth unitStrokeWidth: CGFloat, dstSize: CGSize) -> CGFloat {
        return CGFloat.clamp01(unitStrokeWidth) * min(dstSize.width, dstSize.height)
    }
}
