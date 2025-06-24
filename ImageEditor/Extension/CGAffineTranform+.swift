//
//  CGAffineTranform+.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/16.
//

import Foundation

extension CGAffineTransform {
    
    static func translate(_ point: CGPoint) -> CGAffineTransform {
        CGAffineTransform(translationX: point.x, y: point.y)
    }

    static func scale(_ scaling: CGFloat) -> CGAffineTransform {
        CGAffineTransform(scaleX: scaling, y: scaling)
    }

    static func rotate(_ angleRadians: CGFloat) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: angleRadians)
    }

    func translate(_ point: CGPoint) -> CGAffineTransform {
        translatedBy(x: point.x, y: point.y)
    }

    func scale(_ scaling: CGFloat) -> CGAffineTransform {
        scaledBy(x: scaling, y: scaling)
    }

    func rotate(_ angleRadians: CGFloat) -> CGAffineTransform {
        rotated(by: angleRadians)
    }
}
