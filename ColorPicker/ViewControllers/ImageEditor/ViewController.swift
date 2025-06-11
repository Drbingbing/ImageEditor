//
//  ViewController.swift
//  ColorPicker
//
//  Created by BingBing on 2025/6/10.
//

import UIKit
import PureLayout

class ViewController: UIViewController {
    
    static let preferredToolbarContentWidth: CGFloat = {
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let inset: CGFloat = 16
        return screenWidth - 2*inset
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let drawToolBar = DrawToolBar(currentColor: .defaultColor())
        drawToolBar.preservesSuperviewLayoutMargins = true
        
        view.addSubview(drawToolBar)
        
        drawToolBar.autoPinEdge(toSuperviewMargin: .bottom)
        drawToolBar.autoPinWidthToSuperview()
        
        view.backgroundColor = .secondaryLabel
    }

    
}

