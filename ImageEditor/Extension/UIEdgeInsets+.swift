//
//  UIEdgeInsets+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit

extension UIEdgeInsets {
    
    init(hMargin: CGFloat, vMargin: CGFloat) {
        self.init(top: vMargin, left: hMargin, bottom: vMargin, right: hMargin)
    }

    init(margin: CGFloat) {
        self.init(top: margin, left: margin, bottom: margin, right: margin)
    }

    func plus(_ inset: CGFloat) -> UIEdgeInsets {
        var newInsets = self
        newInsets.top += inset
        newInsets.bottom += inset
        newInsets.left += inset
        newInsets.right += inset
        return newInsets
    }

    func minus(_ inset: CGFloat) -> UIEdgeInsets {
        plus(-inset)
    }

    var asSize: CGSize {
        CGSize(width: left + right, height: top + bottom)
    }
}
