//
//  ImageEditorView.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/13.
//

import UIKit
import PureLayout

final class ImageEditorView: UIView {
    
    let model: ImageEditorModel

    let canvasView: ImageEditorCanvasView
    
    init(model: ImageEditorModel) {
        self.model = model
        canvasView = ImageEditorCanvasView(model: model)
        super.init(frame: .zero)
    }

    @available(*, unavailable, message: "use other init() instead.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        addSubview(canvasView)
        canvasView.configureSubviews()
        canvasView.autoPinEdgesToSuperviewEdges()
    }
    
    final var gestureReferenceView: UIView {
        canvasView.gestureReferenceView
    }
}
