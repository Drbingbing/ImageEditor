//
//  CGPoint+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/11.
//

import Foundation

extension CGPoint {
    
    func toUnitCoordinates(viewBounds: CGRect, shouldClamp: Bool) -> CGPoint {
        CGPoint(x: (x - viewBounds.origin.x).inverseLerp(0, viewBounds.width, shouldClamp: shouldClamp),
                y: (y - viewBounds.origin.y).inverseLerp(0, viewBounds.height, shouldClamp: shouldClamp))
    }

    func toUnitCoordinates(viewSize: CGSize, shouldClamp: Bool) -> CGPoint {
        toUnitCoordinates(viewBounds: CGRect(origin: .zero, size: viewSize), shouldClamp: shouldClamp)
    }

    func fromUnitCoordinates(viewBounds: CGRect) -> CGPoint {
        CGPoint(x: viewBounds.origin.x + x.lerp(0, viewBounds.size.width),
                y: viewBounds.origin.y + y.lerp(0, viewBounds.size.height))
    }

    func fromUnitCoordinates(viewSize: CGSize) -> CGPoint {
        fromUnitCoordinates(viewBounds: CGRect(origin: .zero, size: viewSize))
    }

    func inverse() -> CGPoint {
        CGPoint(x: -x, y: -y)
    }

    func plus(_ value: CGPoint) -> CGPoint {
        CGPoint.add(self, value)
    }

    func plusX(_ value: CGFloat) -> CGPoint {
        CGPoint.add(self, CGPoint(x: value, y: 0))
    }

    func plusY(_ value: CGFloat) -> CGPoint {
        CGPoint.add(self, CGPoint(x: 0, y: value))
    }

    func minus(_ value: CGPoint) -> CGPoint {
        CGPoint.subtract(self, value)
    }

    func times(_ value: CGFloat) -> CGPoint {
        CGPoint(x: x * value, y: y * value)
    }

    func min(_ value: CGPoint) -> CGPoint {
        // We use "Swift" to disambiguate the global function min() from this method.
        CGPoint(x: Swift.min(x, value.x),
                y: Swift.min(y, value.y))
    }

    func max(_ value: CGPoint) -> CGPoint {
        // We use "Swift" to disambiguate the global function max() from this method.
        CGPoint(x: Swift.max(x, value.x),
                y: Swift.max(y, value.y))
    }

    var length: CGFloat {
        sqrt(x * x + y * y)
    }

    @inlinable
    func distance(_ other: CGPoint) -> CGFloat {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }

    @inlinable
    func within(_ delta: CGFloat, of other: CGPoint) -> Bool {
        distance(other) <= delta
    }

    static let unit: CGPoint = CGPoint(x: 1.0, y: 1.0)

    static let unitMidpoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

    func applyingInverse(_ transform: CGAffineTransform) -> CGPoint {
        applying(transform.inverted())
    }

    func fuzzyEquals(_ other: CGPoint, tolerance: CGFloat = 0.001) -> Bool {
        (x.fuzzyEquals(other.x, tolerance: tolerance) &&
            y.fuzzyEquals(other.y, tolerance: tolerance))
    }

    static func tan(angle: CGFloat) -> CGPoint {
        CGPoint(x: sin(angle),
                y: cos(angle))
    }

    func clamp(_ rect: CGRect) -> CGPoint {
        CGPoint(x: x.clamp(rect.minX, rect.maxX),
                y: y.clamp(rect.minY, rect.maxY))
    }

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        left.plus(right)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x * right, y: left.y * right)
    }

    static func *= (left: inout CGPoint, right: CGFloat) {
        left.x *= right
        left.y *= right
    }
}
