//
//  ImageEditorToolbar.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/12.
//

import UIKit

protocol ImageEditorBottomBarButtonProvider: AnyObject {
    
    func middleButtons() -> [UIButton]
}

final class ImageEditorBottombar: UIView {
    
    let cancelButton: UIButton = RoundedMediaButton(
        image: UIImage(imageLiteralResourceName: "x-28"),
        backgroundStyle: .solid(RoundedMediaButton.defaultBackgroundColor)
    )
    
    let doneButton: UIButton = RoundedMediaButton(
        image: UIImage(imageLiteralResourceName: "check-28"),
        backgroundStyle: .solid(RoundedMediaButton.defaultBackgroundColor)
    )
    
    let buttons: [UIButton]
    
    private let stackView = UIStackView()
    
    private var areControlsHidden = false
    private var stackViewPositionConstraint: NSLayoutConstraint?
    
    init(buttonProvider: ImageEditorBottomBarButtonProvider?) {
        let middleButtons = buttonProvider?.middleButtons() ?? []
        buttons = [cancelButton] + middleButtons + [doneButton]
        
        super.init(frame: .zero)
                
        preservesSuperviewLayoutMargins = true
        setContentHuggingVerticalHigh()
        
        if UIDevice.current.hasIPhoneXNotch {
            layoutMargins.bottom = 0
        }
        
        buttons.forEach { button in
            button.setContentHuggingHigh()
            button.setCompressionResistanceVerticalHigh()
        }
        
        let middleStackView = UIStackView(arrangedSubviews: middleButtons)
        middleStackView.spacing = 2
        stackView.addArrangedSubviews([cancelButton, middleStackView, doneButton])
        stackView.distribution = .equalSpacing
        stackView.isOpaque = false
        addSubview(stackView)
        stackView.autoPinLeadingToSuperviewMargin(withInset: -cancelButton.layoutMargins.left)
        stackView.autoPinTrailingToSuperviewMargin(withInset: -doneButton.layoutMargins.right)
        stackView.heightAnchor.constraint(equalTo: layoutMarginsGuide.heightAnchor).isActive = true
        setControls(hidden: false)
    }
    
    @available(*, unavailable, message: "Use init(buttonProvider:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setControls(hidden: Bool) {
        guard hidden != areControlsHidden || stackViewPositionConstraint == nil else { return }

        if let stackViewPositionConstraint = stackViewPositionConstraint {
            removeConstraint(stackViewPositionConstraint)
            self.stackViewPositionConstraint = nil
        }

        let stackViewPositionConstraint: NSLayoutConstraint
        if hidden {
            stackViewPositionConstraint = stackView.topAnchor.constraint(equalTo: bottomAnchor)
        } else {
            stackViewPositionConstraint = stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        }
        addConstraint(stackViewPositionConstraint)
        self.stackViewPositionConstraint = stackViewPositionConstraint

        areControlsHidden = hidden
    }
}
