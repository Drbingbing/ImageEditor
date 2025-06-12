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
            updateDrawToolUIVisibility()
        }
    }
    
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
        super.viewDidLoad()
        
        view.backgroundColor = .black
    }
    
    @objc func strokeTypeButtonTapped(_ sender: UIButton) {
        drawToolbar.strokeTypeButton.isSelected.toggle()
    }
}
