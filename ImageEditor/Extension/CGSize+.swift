//
//  CGSize+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/11.
//

import Foundation

extension CGSize {
    
    var aspectRatio: CGFloat {
        guard self.height > 0 else {
            return 0
        }

        return self.width / self.height
    }

    var asPoint: CGPoint {
        CGPoint(x: width, y: height)
    }

    var ceil: CGSize {
        CGSize.ceil(self)
    }

    var floor: CGSize {
        CGSize.floor(self)
    }

    var round: CGSize {
        CGSize.round(self)
    }

    var abs: CGSize {
        CGSize(width: Swift.abs(width), height: Swift.abs(height))
    }

    var largerAxis: CGFloat {
        Swift.max(width, height)
    }

    var smallerAxis: CGFloat {
        min(width, height)
    }

    var isNonEmpty: Bool {
        width > 0 && height > 0
    }

    init(square: CGFloat) {
        self.init(width: square, height: square)
    }

    func plus(_ value: CGSize) -> CGSize {
        CGSize.add(self, value)
    }

    func max(_ other: CGSize) -> CGSize {
        return CGSize(width: Swift.max(self.width, other.width),
                      height: Swift.max(self.height, other.height))
    }

    static func square(_ size: CGFloat) -> CGSize {
        CGSize(width: size, height: size)
    }

    static func + (left: CGSize, right: CGSize) -> CGSize {
        left.plus(right)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width - right.width,
               height: left.height - right.height)
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right,
               height: left.height * right)
    }
}
