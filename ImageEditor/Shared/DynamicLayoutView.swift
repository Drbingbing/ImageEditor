//
//  DynamicLayoutView.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit

class DynamicLayoutView: UIView {
    
    var shouldAnimate: Bool = true
    
    var layoutCallback: (UIView) -> Void
    
    init() {
        layoutCallback = { _ in }
        super.init(frame: .zero)
    }
    
    init(frame: CGRect, layoutCallback: @escaping (UIView) -> Void) {
        self.layoutCallback = layoutCallback
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.layoutCallback = { _ in }
        super.init(coder: aDecoder)
    }
    
    override var bounds: CGRect {
        didSet {
            if oldValue != bounds {
                layoutSubviews()
            }
        }
    }

    override var frame: CGRect {
        didSet {
            if oldValue != frame {
                layoutSubviews()
            }
        }
    }
    
    override var center: CGPoint {
        didSet {
            if oldValue != center {
                layoutSubviews()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutCallback(self)
    }
    
    func updateContent() {
        if shouldAnimate {
            layoutSubviews()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layoutSubviews()
            CATransaction.commit()
        }
    }
}
