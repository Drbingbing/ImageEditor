//
//  UIColor+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit

extension UIColor {
    
    func blended(with otherColor: UIColor, alpha alphaParam: CGFloat) -> UIColor {
        var r0: CGFloat = 0
        var g0: CGFloat = 0
        var b0: CGFloat = 0
        var a0: CGFloat = 0
        let result0 = self.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
        assert(result0)

        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        let result1 = otherColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        assert(result1)

        let alpha = CGFloat.clamp01(alphaParam)
        return UIColor(red: CGFloat.lerp(left: r0, right: r1, alpha: alpha),
                       green: CGFloat.lerp(left: g0, right: g1, alpha: alpha),
                       blue: CGFloat.lerp(left: b0, right: b1, alpha: alpha),
                       alpha: CGFloat.lerp(left: a0, right: a1, alpha: alpha))

    }
    
    convenience init(rgbHex value: UInt32) {
        let red = CGFloat(((value >> 16) & 0xff)) / 255.0
        let green = CGFloat(((value >> 8) & 0xff)) / 255.0
        let blue = CGFloat(((value >> 0) & 0xff)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    convenience init(rgbHex value: UInt32, alpha: CGFloat) {
        let red = CGFloat(((value >> 16) & 0xff)) / 255.0
        let green = CGFloat(((value >> 8) & 0xff)) / 255.0
        let blue = CGFloat(((value >> 0) & 0xff)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

}
