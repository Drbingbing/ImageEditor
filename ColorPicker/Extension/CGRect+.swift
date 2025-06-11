//
//  CGRect+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/11.
//

import Foundation

extension CGRect {
    
    var x: CGFloat {
        get {
            origin.x
        }
        set {
            origin.x = newValue
        }
    }

    var y: CGFloat {
        get {
            origin.y
        }
        set {
            origin.y = newValue
        }
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    var topLeft: CGPoint {
        origin
    }

    var topRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }

    var bottomLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }

    var bottomRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }

    func pinnedToVerticalEdge(of boundingRect: CGRect) -> CGRect {
        var newRect = self

        // If we're positioned outside of the vertical bounds,
        // we need to move to the nearest bound
        let positionedOutOfVerticalBounds = newRect.minY < boundingRect.minY || newRect.maxY > boundingRect.maxY

        // If we're position anywhere but exactly at the vertical
        // edges (left and right of bounding rect), we need to
        // move to the nearest edge
        let positionedAwayFromVerticalEdges = boundingRect.minX != newRect.minX && boundingRect.maxX != newRect.maxX

        if positionedOutOfVerticalBounds {
            let distanceFromTop = newRect.minY - boundingRect.minY
            let distanceFromBottom = boundingRect.maxY - newRect.maxY

            if distanceFromTop > distanceFromBottom {
                newRect.origin.y = boundingRect.maxY - newRect.height
            } else {
                newRect.origin.y = boundingRect.minY
            }
        }

        if positionedAwayFromVerticalEdges {
            let distanceFromLeading = newRect.minX - boundingRect.minX
            let distanceFromTrailing = boundingRect.maxX - newRect.maxX

            if distanceFromLeading > distanceFromTrailing {
                newRect.origin.x = boundingRect.maxX - newRect.width
            } else {
                newRect.origin.x = boundingRect.minX
            }
        }

        return newRect
    }
}
