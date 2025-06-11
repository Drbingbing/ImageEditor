//
//  UIView+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit

extension UIView {
    
    var left: CGFloat { frame.minX }

    var right: CGFloat { frame.maxX }

    var top: CGFloat { frame.minY }

    var bottom: CGFloat { frame.maxY }

    var width: CGFloat { frame.width }

    var height: CGFloat { frame.height }
    
    
    func renderAsImage() -> UIImage {
        renderAsImage(opaque: false, scale: UIScreen.main.scale)
    }
    
    func renderAsImage(opaque: Bool, scale: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = opaque
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds,
                                               format: format)
        return renderer.image { (context) in
            self.layer.render(in: context.cgContext)
        }
    }
}
