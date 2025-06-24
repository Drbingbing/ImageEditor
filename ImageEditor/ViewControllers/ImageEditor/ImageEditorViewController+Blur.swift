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
        func removeCurrentBlur() {
            if let blur = currentStroke {
                model.remove(item: blur)
            }
            currentStroke = nil
            currentStrokeSamples.removeAll()
        }
        
        func tryToAppendBlurSample(_ locationInView: CGPoint) {
            let view = imageEditorView.gestureReferenceView
            let viewBounds = view.bounds
            let newSample = ImageEditorCanvasView.locationImageUnit(forLocationInView: locationInView,
                                                                    viewBounds: viewBounds,
                                                                    model: model,
                                                                    transform: model.currentTransform())
            if let prevSample = currentStrokeSamples.last,
               prevSample == newSample {
                return
            }
            
            currentStrokeSamples.append(newSample)
        }
        
        let unitBlurStrokeWidth = currentStrokeUnitWidth()
        
        switch gestureRecognizer.state {
        case .began:
            removeCurrentBlur()
            for location in gestureRecognizer.locationHistory {
                tryToAppendBlurSample(location)
            }

            let locationInView = gestureRecognizer.location(in: imageEditorView.gestureReferenceView)
            tryToAppendBlurSample(locationInView)
            
            let blur = ImageEditorStrokeItem(strokeType: .blur,
                                             unitSamples: currentStrokeSamples,
                                             unitStrokeWidth: unitBlurStrokeWidth)
            
            model.append(item: blur)
            currentStroke = blur
            
        case .changed, .ended:
            let locationInView = gestureRecognizer.location(in: imageEditorView.gestureReferenceView)
            tryToAppendBlurSample(locationInView)
            
            guard let lastBlur = currentStroke else {
                ieFailDebug("Missing last blur")
                return
            }
            
            let blurStorke = ImageEditorStrokeItem(itemId: lastBlur.itemId,
                                                   strokeType: .blur,
                                                   unitSamples: currentStrokeSamples,
                                                   unitStrokeWidth: unitBlurStrokeWidth)
            model.replace(item: blurStorke)
            
            if gestureRecognizer.state == .ended {
                currentStroke = nil
                currentStrokeSamples.removeAll()
            } else {
                currentStroke = blurStorke
            }
            
        default:
            removeCurrentBlur()
        }
    }
}
