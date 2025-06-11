//
//  PillView.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit
import PureLayout

final class PillView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.masksToBounds = true
        autoPin(toAspectRatio: 1.0, relation: .greaterThanOrEqual)
        
        NSLayoutConstraint.autoSetPriority(.defaultLow) {
            self.autoSetDimension(.height, toSize: 0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var frame: CGRect {
        didSet {
            updateRadius()
        }
    }

    override public var bounds: CGRect {
        didSet {
            updateRadius()
        }
    }

    private func updateRadius() {
        layer.cornerRadius = bounds.size.height / 2
    }
}
