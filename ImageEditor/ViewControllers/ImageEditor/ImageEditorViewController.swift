//
//  ImageEditorViewController.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit
import PureLayout

class ImageEditorViewController: UIViewController {
    
    enum Mode: Int {
        case draw = 1
        case blur
        case text
        case sticker
    }
    
    var mode: Mode = .draw {
        didSet {
            if oldValue != mode && isViewLoaded {
                updateUIForCurrentMode()
            }
        }
    }
    
    lazy var imageEditorView = {
        let editorView = ImageEditorView()
        return editorView
    }()
    
    lazy var bottomBar = ImageEditorBottombar(buttonProvider: self)
    
    lazy var drawToolbar: DrawToolbar = {
        let toolbar = DrawToolbar(currentColor: .defaultColor())
        toolbar.preservesSuperviewLayoutMargins = true
        toolbar.strokeTypeButton.addTarget(self, action: #selector(strokeTypeButtonTapped), for: .touchUpInside)
        return toolbar
    }()
    
    lazy var blurToolbar = {
        let drawAnyWhereHint = UILabel()
        drawAnyWhereHint.font = .dynamicTypeCaption1
        drawAnyWhereHint.textColor = .white
        drawAnyWhereHint.textAlignment = .center
        drawAnyWhereHint.numberOfLines = 0
        drawAnyWhereHint.lineBreakMode = .byWordWrapping
        drawAnyWhereHint.text = "繪製任何地方使之模糊"
        drawAnyWhereHint.layer.shadowColor = UIColor.black.cgColor
        drawAnyWhereHint.layer.shadowRadius = 2
        drawAnyWhereHint.layer.shadowOpacity = 0.66
        drawAnyWhereHint.layer.shadowOffset = .zero
        
        let stackView = UIStackView(arrangedSubviews: [faceBlurContainer, drawAnyWhereHint])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 14
        
        return stackView
    }()
    
    lazy var faceBlurContainer = {
        let containerView = PillView()
        containerView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 8)
        
        let blurBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        containerView.addSubview(blurBackgroundView)
        blurBackgroundView.autoPinEdgesToSuperviewEdges()
        
        let autoBlurLabel = UILabel()
        autoBlurLabel.text = "模糊臉部"
        autoBlurLabel.textColor = .white
        autoBlurLabel.font = .dynamicTypeSubheadlineClamped
        
        let stackView = UIStackView(arrangedSubviews: [autoBlurLabel, faceBlurSwitch])
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.axis = .horizontal
        containerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewMargins()
        
        return containerView
    }()
    
    lazy var faceBlurSwitch = {
        let faceBlurSwitch = UISwitch()
        faceBlurSwitch.addTarget(self, action: #selector(didToggleAutoBlur), for: .valueChanged)
        faceBlurSwitch.isOn = false
        return faceBlurSwitch
    }()
    lazy var blurToolGestureRecognizer: ImageEditorPanGestureRecognizer = {
        let gestureRecognizer = ImageEditorPanGestureRecognizer(target: self, action: #selector(handleBlurToolGesture))
        gestureRecognizer.maximumNumberOfTouches = 1
        gestureRecognizer.referenceView = imageEditorView.gestureReferenceView
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()
    
    static let preferredToolbarContentWidth: CGFloat = {
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let inset: CGFloat = 16
        return screenWidth - 2*inset
    }()

    override func viewDidLoad() {
        view.backgroundColor = .black
        
        imageEditorView.configureSubviews()
        view.addSubview(imageEditorView)
        imageEditorView.autoPinWidthToSuperview()
        imageEditorView.autoPinEdge(toSuperviewSafeArea: .top)
        
        view.addSubview(bottomBar)
        bottomBar.autoPinWidthToSuperview()
        bottomBar.autoPinEdge(toSuperviewEdge: .bottom)
        bottomBar.autoPinEdge(.top, to: .bottom, of: imageEditorView)
        
        bottomBar.cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        bottomBar.doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        updateUIForCurrentMode()
    }
    
    
    private func updateUIForCurrentMode() {
        updateDrawToolUIVisibility()
        updateBlurToolUIVisibility()
        
        for button in bottomBar.buttons {
            button.isSelected = mode.rawValue == button.tag
        }
    }
}

extension ImageEditorViewController: ImageEditorBottomBarButtonProvider {
    
    func middleButtons() -> [UIButton] {
        
        let penButton = RoundedMediaButton(
            image: UIImage(imageLiteralResourceName: "edit-28"),
            backgroundStyle: .solid(.clear)
        )
        penButton.tag = Mode.draw.rawValue
        penButton.addTarget(self, action: #selector(didTapPen), for: .touchUpInside)
        
        let textButton = RoundedMediaButton(
            image: UIImage(imageLiteralResourceName: "text-28"),
            backgroundStyle: .solid(.clear)
        )
        textButton.addTarget(self, action: #selector(didTapAddText), for: .touchUpInside)
        
        let stickerButton = RoundedMediaButton(
            image: UIImage(imageLiteralResourceName: "sticker-smiley-28"),
            backgroundStyle: .solid(.clear)
        )
        stickerButton.addTarget(self, action: #selector(didTapAddSticker), for: .touchUpInside)
        
        let blurButton = RoundedMediaButton(
            image: UIImage(imageLiteralResourceName: "blur-28"),
            backgroundStyle: .solid(.clear)
        )
        blurButton.tag = Mode.blur.rawValue
        blurButton.addTarget(self, action: #selector(didTapBlur), for: .touchUpInside)
        
        let buttons = [penButton, textButton, stickerButton, blurButton]
        for button in buttons {
            button.setBackgroundColor(.white, for: .highlighted)
            button.setBackgroundColor(.white, for: .selected)
            if let image = button.image(for: .normal) {
                let tintedImage = image.withTintColor(.black, renderingMode: .alwaysOriginal)
                button.setImage(tintedImage, for: .highlighted)
                button.setImage(tintedImage, for: .selected)
            }
        }
        
        return buttons
    }
}

extension ImageEditorViewController {
    
    @objc func strokeTypeButtonTapped(_ sender: UIButton) {
        drawToolbar.strokeTypeButton.isSelected.toggle()
    }
    
    @objc
    private func didTapPen(_ sender: UIButton) {
        mode = (mode == .draw) ? .text : .draw
    }
    
    @objc
    private func didTapAddText(_ sender: UIButton) {
        
    }
    
    @objc
    private func didTapAddSticker(_ sender: UIButton) {
        
    }
    
    @objc
    private func didTapBlur(_ sender: UIButton) {
        mode = (mode == .blur) ? .text : .blur
    }
    
    @objc
    private func didTapCancel(_ sender: UIButton) {
        
    }
    
    @objc
    private func didTapDone(_ sender: UIButton) {
        
    }
    
    @objc
    private func didToggleAutoBlur(_ sender: UISwitch) {
        
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ImageEditorViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch mode {
        case .draw:
            guard !drawToolbar.bounds.contains(touch.location(in: drawToolbar)) else {
                return false
            }
            
            return true
        case .blur:
            return !blurToolbar.bounds.contains(touch.location(in: blurToolbar))
            
        default:
            return true
        }
    }
}
