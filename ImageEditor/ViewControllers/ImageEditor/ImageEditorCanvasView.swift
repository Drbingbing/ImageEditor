//
//  ImageEditorCanvasView.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/13.
//

import UIKit

final class ImageEditorCanvasView: UIView {
    
    // clipView is used to clip the content.  It reflects the actual
    // visible bounds of the "canvas" content.
    private let clipView = DynamicLayoutView()
    
    private var contentViewConstraints = [NSLayoutConstraint]()

    
    func configureSubviews() {
        
        backgroundColor = .clear
        isOpaque = true
        
        clipView.clipsToBounds = true
        clipView.isOpaque = false
        clipView.layoutCallback = { [weak self] _ in
            self?.updateLayout()
        }
        addSubview(clipView)
        
        updateLayout()
    }
    
    var gestureReferenceView: UIView {
        return clipView
    }
    
    private func updateLayout() {
        NSLayoutConstraint.deactivate(contentViewConstraints)
        contentViewConstraints = Self.updateContentLayout(contentView: clipView)
    }
    
    class func updateContentLayout(contentView: UIView) -> [NSLayoutConstraint] {
        guard let superview = contentView.superview else {
            debugPrint("Content view has no superview.")
            return []
        }
        
        let aspectRatio: CGSize = CGSize(width: 300, height: 300)
        
        // This emulates the behavior of contentMode = .scaleAspectFit using iOS auto layout constraints.
        var constraints = [NSLayoutConstraint]()
        NSLayoutConstraint.autoSetPriority(.defaultHigh + 100) {
            constraints.append(contentView.autoAlignAxis(.vertical, toSameAxisOf: superview))
            constraints.append(contentView.autoAlignAxis(.horizontal, toSameAxisOf: superview))
        }
        constraints.append(contentView.autoPinEdge(.top, to: .top, of: superview, withOffset: 0, relation: .greaterThanOrEqual))
        constraints.append(contentView.autoPinEdge(.bottom, to: .bottom, of: superview, withOffset: 0, relation: .lessThanOrEqual))
        constraints.append(contentView.autoPin(toAspectRatio: aspectRatio.width / aspectRatio.height))
        constraints.append(contentView.autoMatch(.width, to: .width, of: superview, withMultiplier: 1.0, relation: .lessThanOrEqual))
        constraints.append(contentView.autoMatch(.height, to: .height, of: superview, withMultiplier: 1.0, relation: .lessThanOrEqual))
        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            constraints.append(contentView.autoMatch(.width, to: .width, of: superview, withMultiplier: 1.0, relation: .equal))
            constraints.append(contentView.autoMatch(.height, to: .height, of: superview, withMultiplier: 1.0, relation: .equal))
        }

        let superviewSize = superview.frame.size
        let maxSuperviewDimension = max(superviewSize.width, superviewSize.height)
        let outputSizePoints = CGSize(square: maxSuperviewDimension)
        NSLayoutConstraint.autoSetPriority(.defaultLow) {
            constraints.append(contentsOf: contentView.autoSetDimensions(to: outputSizePoints))
        }
        return constraints
    }
}
