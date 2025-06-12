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
        let editorView = UIView()
        editorView.backgroundColor = .clear
        return editorView
    }()
    
    lazy var bottomBar = ImageEditorBottombar(buttonProvider: self)
    
    lazy var drawToolbar: DrawToolbar = {
        let toolbar = DrawToolbar(currentColor: .defaultColor())
        toolbar.preservesSuperviewLayoutMargins = true
        toolbar.strokeTypeButton.addTarget(self, action: #selector(strokeTypeButtonTapped), for: .touchUpInside)
        return toolbar
    }()
    
    static let preferredToolbarContentWidth: CGFloat = {
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let inset: CGFloat = 16
        return screenWidth - 2*inset
    }()

    override func viewDidLoad() {
        view.backgroundColor = .black
        
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
}
