//
//  AutoLayout+.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit
import PureLayout

extension UIView {
    // MARK: Centering

    @discardableResult
    func autoHCenterInSuperview() -> NSLayoutConstraint {
        return autoAlignAxis(.vertical, toSameAxisOf: superview!)
    }

    @discardableResult
    func autoVCenterInSuperview() -> NSLayoutConstraint {
        return autoAlignAxis(.horizontal, toSameAxisOf: superview!)
    }

    // MARK: Aspect Ratio

    @discardableResult
    func autoPinToSquareAspectRatio() -> NSLayoutConstraint {
        return autoPin(toAspectRatio: 1)
    }

    @discardableResult
    func autoPinToAspectRatio(withSize size: CGSize) -> NSLayoutConstraint {
        return autoPin(toAspectRatio: size.aspectRatio)
    }

    @discardableResult
    func autoPin(toAspectRatio ratio: CGFloat, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        // Clamp to ensure view has reasonable aspect ratio.
        let clampedRatio: CGFloat = CGFloat.clamp(ratio, min: 0.05, max: 95.0)
        if clampedRatio != ratio {
            debugPrint("Invalid aspect ratio: \(ratio) for view: \(self)")
        }

        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: relation,
            toItem: self,
            attribute: .height,
            multiplier: clampedRatio,
            constant: 0)
        constraint.autoInstall()
        
        return constraint
    }
    
    @discardableResult
    func autoPinEdges(toEdgesOf view: UIView, with insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [
            autoPinEdge(.leading, to: .leading, of: view, withOffset: insets.left),
            autoPinEdge(.top, to: .top, of: view, withOffset: insets.top),
            autoPinEdge(.trailing, to: .trailing, of: view, withOffset: -insets.right),
            autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -insets.bottom)
        ]
    }
    
    @discardableResult
    func autoPinWidthToSuperview(withMargin margin: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        // We invert the relation because of the weird grammar switch when talking about
        // the size of widths to the positioning of edges
        // "Width less than or equal to superview margin width"
        // -> "Leading edge greater than or equal to superview leading edge"
        // -> "Trailing edge less than or equal to superview trailing edge" (then PureLayout re-inverts for whatever reason)
        let resolvedRelation = relation.inverse
        return [
            autoPinEdge(toSuperviewEdge: .leading, withInset: margin, relation: resolvedRelation),
            autoPinEdge(toSuperviewEdge: .trailing, withInset: margin, relation: resolvedRelation)
        ]
    }
    
    
    // MARK: Content Hugging and Compression Resistance

    func setContentHuggingLow() {
        setContentHuggingHorizontalLow()
        setContentHuggingVerticalLow()
    }

    func setContentHuggingHigh() {
        setContentHuggingHorizontalHigh()
        setContentHuggingVerticalHigh()
    }

    func setContentHuggingHorizontalLow() {
        setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    func setContentHuggingHorizontalHigh() {
        setContentHuggingPriority(.required, for: .horizontal)
    }

    func setContentHuggingVerticalLow() {
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    func setContentHuggingVerticalHigh() {
        setContentHuggingPriority(.required, for: .vertical)
    }

    func setCompressionResistanceLow() {
        setCompressionResistanceHorizontalLow()
        setCompressionResistanceVerticalLow()
    }

    func setCompressionResistanceHigh() {
        setCompressionResistanceHorizontalHigh()
        setCompressionResistanceVerticalHigh()
    }

    func setCompressionResistanceHorizontalLow() {
        setContentCompressionResistancePriority(.init(0), for: .horizontal)
    }

    func setCompressionResistanceHorizontalHigh() {
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func setCompressionResistanceVerticalLow() {
        setContentCompressionResistancePriority(.init(0), for: .vertical)
    }

    func setCompressionResistanceVerticalHigh() {
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

}


extension NSLayoutConstraint.Relation {
    var inverse: NSLayoutConstraint.Relation {
        switch self {
        case .lessThanOrEqual: return .greaterThanOrEqual
        case .equal: return .equal
        case .greaterThanOrEqual: return .lessThanOrEqual
        @unknown default:
            return .equal
        }
    }
}
