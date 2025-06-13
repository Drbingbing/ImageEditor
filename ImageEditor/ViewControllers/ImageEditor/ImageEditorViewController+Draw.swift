//
//  ViewController+DrawToolBar.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/11.
//

import UIKit
import PureLayout

private let drawToolUIInitializedKey = malloc(4)

extension ImageEditorViewController {
    
    private var drawToolUIInitialized: Bool {
        get {
            let result = objc_getAssociatedObject(self, drawToolUIInitializedKey!)
            return result as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, drawToolUIInitializedKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func initializeDrawToolUIIfNecessary() {
        guard !drawToolUIInitialized else { return }
        
        view.addSubview(drawToolbar)
        
        drawToolbar.autoPinWidthToSuperview()
        drawToolbar.autoPinEdge(.bottom, to: .top, of: bottomBar)
        
        drawToolUIInitialized = true
    }
    
    func updateDrawToolUIVisibility() {
        let visible = mode == .draw
        
        if visible {
            initializeDrawToolUIIfNecessary()
        } else {
            guard drawToolUIInitialized else { return }
        }
        
        drawToolbar.isHidden = false
        
        UIView.animate(withDuration: 0.15) {
            self.drawToolbar.alpha = visible ? 1 : 0
        } completion: { _ in
            self.drawToolbar.isHidden = !visible
        }
    }
    
    class DrawToolbar: UIView {
        
        let colorPickerView: ColorPickerBarView
        
        let strokeTypeButton = RoundedMediaButton(
            image: UIImage(imageLiteralResourceName: "brush-pen"),
            backgroundStyle: .blur
        )
        
        init(currentColor: ColorPickerBarColor) {
            self.colorPickerView = ColorPickerBarView(currentColor: currentColor)
            super.init(frame: .zero)
            
            layoutMargins.top = 0
            layoutMargins.bottom = 0
            
            strokeTypeButton.setImage(UIImage(imageLiteralResourceName: "brush-highlighter"), for: .selected)
            
            let stackviewLayoutGuide = UILayoutGuide()
            addLayoutGuide(stackviewLayoutGuide)
            addConstraints([
                stackviewLayoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor),
                stackviewLayoutGuide.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
                stackviewLayoutGuide.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                stackviewLayoutGuide.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ])
            addConstraint({
                let constraint = stackviewLayoutGuide.widthAnchor.constraint(equalToConstant: ImageEditorViewController.preferredToolbarContentWidth)
                constraint.priority = .defaultHigh
                return constraint
            }())
            
            let stackView = UIStackView(arrangedSubviews: [colorPickerView, strokeTypeButton])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.alignment = .center
            stackView.spacing = 8
            addSubview(stackView)
            addConstraints([
                stackView.leadingAnchor.constraint(equalTo: stackviewLayoutGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: stackviewLayoutGuide.trailingAnchor, constant: strokeTypeButton.layoutMargins.right),
                stackView.topAnchor.constraint(equalTo: stackviewLayoutGuide.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: stackviewLayoutGuide.bottomAnchor)
            ])
        }
        
        @available(iOS, unavailable, message: "Use init(currentColor:)")
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
