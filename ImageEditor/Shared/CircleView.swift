//
//  CircleView.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/11.
//

import UIKit
import PureLayout

final class CircleView: UIView {
    
    
    @available(*, unavailable, message: "use other constructor instead.")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
    }
    
    init(diameter: CGFloat) {
        super.init(frame: .zero)

        autoSetDimensions(to: CGSize(square: diameter))
    }
    
    override var frame: CGRect {
        didSet {
            updateRadius()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updateRadius()
        }
    }
    
    private func updateRadius() {
        layer.cornerRadius = bounds.size.height / 2
    }
}
