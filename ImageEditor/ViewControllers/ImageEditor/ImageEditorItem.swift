//
//  ImageEditorItem.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/16.
//

import Foundation

// Represented in a "ULO unit" coordinate system
// for source image.
//
// "ULO" coordinate system is "upper-left-origin".
//
// "Unit" coordinate system means values are expressed
// in terms of some other values, in this case the
// width and height of the source image.
//
// * 0.0 = left edge
// * 1.0 = right edge
// * 0.0 = top edge
// * 1.0 = bottom edge
typealias ImageEditorSample = CGPoint

enum ImageEditorItemType: Int {
    case stroke
}

class ImageEditorItem {
    
    let itemId: String

    let itemType: ImageEditorItemType

    init(itemType: ImageEditorItemType) {
        self.itemId = UUID().uuidString
        self.itemType = itemType
    }

    init(itemId: String, itemType: ImageEditorItemType) {
        self.itemId = itemId
        self.itemType = itemType
    }

    // The scale with which to render this item's content
    // when rendering the "output" image for sending.
    func outputScale() -> CGFloat {
        return 1.0
    }
}

