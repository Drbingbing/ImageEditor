//
//  ImageEditorViewController+Blur.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/13.
//

import UIKit

private let blurToolUIInitializedKey = malloc(4)

extension ImageEditorViewController {
    
    private var blurToolUIInitialized: Bool {
        get {
            let result = objc_getAssociatedObject(self, blurToolUIInitializedKey!)
            return result as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, blurToolUIInitializedKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func initializeBlurToolUIIfNecessary() {
        view.addSubview(blurToolbar)
        blurToolbar.autoHCenterInSuperview()
        blurToolbar.autoPinEdge(.bottom, to: .top, of: bottomBar, withOffset: -36)

        view.addGestureRecognizer(blurToolGestureRecognizer)

        blurToolUIInitialized = true
    }
    
    func updateBlurToolUIVisibility() {
        let visible = mode == .blur
        
        if visible {
            initializeBlurToolUIIfNecessary()
        } else {
            guard blurToolUIInitialized else { return }
        }
        
        blurToolbar.isHidden = false
        blurToolGestureRecognizer.isEnabled = visible
        
        UIView.animate(withDuration: 0.15) {
            self.blurToolbar.alpha = visible ? 1 : 0
        } completion: { _ in
            self.blurToolbar.isHidden = !visible
        }
    }
    
    @objc func handleBlurToolGesture(_ gestureRecognizer: ImageEditorPanGestureRecognizer) {
        
    }
}
