//
//  NSDirectionalEdgeInsets+.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/13.
//

import UIKit

extension NSDirectionalEdgeInsets {
    init(hMargin: CGFloat, vMargin: CGFloat) {
        self.init(top: vMargin, leading: hMargin, bottom: vMargin, trailing: hMargin)
    }

    init(margin: CGFloat) {
        self.init(top: margin, leading: margin, bottom: margin, trailing: margin)
    }
}
