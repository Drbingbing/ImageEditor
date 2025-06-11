//
//  CGFloat+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import Foundation

extension CGFloat {
    
    func clamp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        return CGFloat.clamp(self, min: minValue, max: maxValue)
    }

    func clamp01() -> CGFloat {
        return CGFloat.clamp01(self)
    }

    /// Returns a random value within the specified range with a fixed number of discrete choices.
    ///
    /// ```
    /// CGFloat.random(in: 0..10, choices: 2)  // => 5
    /// CGFloat.random(in: 0..10, choices: 2)  // => 0
    /// CGFloat.random(in: 0..10, choices: 2)  // => 5
    ///
    /// CGFloat.random(in: 0..10, choices: 10)  // => 8
    /// CGFloat.random(in: 0..10, choices: 10)  // => 4
    /// CGFloat.random(in: 0..10, choices: 10)  // => 0
    /// ```
    ///
    /// - Parameters:
    ///   - range: The range in which to create a random value.
    ///     `range` must be finite and nonempty.
    ///   - choices: The number of discrete choices for the result.
    /// - Returns: A random value within the bounds of `range`, constrained to the number of `choices`.
    static func random(in range: Range<CGFloat>, choices: UInt) -> CGFloat {
        let rangeSize = range.upperBound - range.lowerBound
        let choice = UInt.random(in: 0..<choices)
        return range.lowerBound + (rangeSize * CGFloat(choice) / CGFloat(choices))
    }

    // Linear interpolation
    func lerp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        return CGFloat.lerp(left: minValue, right: maxValue, alpha: self)
    }

    // Inverse linear interpolation
    func inverseLerp(_ minValue: CGFloat, _ maxValue: CGFloat, shouldClamp: Bool = false) -> CGFloat {
        let value = CGFloat.inverseLerp(self, min: minValue, max: maxValue)
        return (shouldClamp ? CGFloat.clamp01(value) : value)
    }

    static let halfPi: CGFloat = CGFloat.pi * 0.5

    func fuzzyEquals(_ other: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
        return abs(self - other) < tolerance
    }

    var square: CGFloat {
        return self * self
    }

    func average(_ other: CGFloat) -> CGFloat {
        (self + other) * 0.5
    }
}
