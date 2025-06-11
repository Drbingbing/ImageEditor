//
//  RoundedMediaButton.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/11.
//

import UIKit
import PureLayout

final class RoundedMediaButton: UIButton {
    
    enum BackgroundStyle {
        case none
        case solid(UIColor)
        case blur(UIBlurEffect.Style)
        
        static let blur: BackgroundStyle = .blur(.dark)
        static let blurLight: BackgroundStyle = .blur(.light)
    }
    
    let backgroundStyle: BackgroundStyle
    
    private var backgroundContainerView: UIView?
    private let backgroundView: UIView?
    private var backgroundDimmerView: UIView?
    
    static let defaultBackgroundColor = UIColor(rgbHex: 0x2E2E2E)
    static let visibleButtonSize: CGFloat = 42
    
    private static let defaultInset: CGFloat = 8
    private static let defaultContentInset: CGFloat = 15
    
    convenience init(image: UIImage?, backgroundStyle: BackgroundStyle) {
        self.init(image: image, backgroundStyle: backgroundStyle, customView: nil)
    }
     
    init(image: UIImage?, backgroundStyle: BackgroundStyle, customView: UIView?) {
        self.backgroundStyle = backgroundStyle
        self.backgroundView = {
            switch backgroundStyle {
            case .none:
                return nil
            case .solid:
                return UIView()
            case .blur(let style):
                return UIVisualEffectView(effect: UIBlurEffect(style: style))
            }
        }()
        
        super.init(frame: CGRect(origin: .zero, size: .square(Self.visibleButtonSize + 2*Self.defaultInset)))
        
        layoutMargins = UIEdgeInsets(margin: Self.defaultInset)
        tintColor = .systemBlue
        insetsLayoutMarginsFromSafeArea = false
        
        setCompressionResistanceHigh()
        
        if backgroundView != nil || customView != nil {
            let backgroundContainerView = UIView()
            backgroundContainerView.isUserInteractionEnabled = false
            addSubview(backgroundContainerView)
            backgroundContainerView.autoPinEdgesToSuperviewMargins()
            self.backgroundContainerView = backgroundContainerView
            
            if let backgroundView {
                backgroundView.isUserInteractionEnabled = false
                backgroundContainerView.addSubview(backgroundView)
                backgroundView.autoPinEdgesToSuperviewMargins()
            }
            
            if let customView {
                backgroundContainerView.addSubview(customView)
                customView.autoCenterInSuperview()
            }
            
            let backgroundDimmerView = UIView(frame: backgroundContainerView.bounds)
            backgroundDimmerView.backgroundColor = UIColor(white: 0, alpha: 0.467)
            backgroundDimmerView.alpha = 0
            backgroundContainerView.addSubview(backgroundDimmerView)
            backgroundDimmerView.autoPinEdgesToSuperviewEdges()
            self.backgroundDimmerView = backgroundDimmerView
        }
        
        setImage(image, for: .normal)
        
        if case .solid(let color) = backgroundStyle {
            setBackgroundColor(color, for: .normal)
        }
    }
    
    @available(*, unavailable, message: "Use init(image:backgroundStyle:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(image:backgroundStyle:) instead")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let backgroundContainerView = backgroundContainerView {
            sendSubviewToBack(backgroundContainerView)
        }
    }
    
    private var backgroundColors: [ UIControl.State.RawValue: UIColor ] = [:]
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        if let color = color {
            backgroundColors[state.rawValue] = color
        } else {
            backgroundColors.removeValue(forKey: state.rawValue)
        }
        if self.state == state {
            updateBackgroundColor()
        }
    }
    
    func backgroundColor(for state: UIControl.State) -> UIColor? {
        return backgroundColors[state.rawValue]
    }

    private func updateBackgroundColor() {
        // Use default dimming if separate background color for 'highlighted' isn't specified.
        if backgroundColor(for: .highlighted) == nil {
            backgroundDimmerView?.alpha = isHighlighted ? 1 : 0
        }

        switch backgroundStyle {
        case .solid:
            backgroundView?.backgroundColor = backgroundColor(for: state) ?? backgroundColor(for: .normal)

        default:
            break
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateBackgroundColor()
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
}
