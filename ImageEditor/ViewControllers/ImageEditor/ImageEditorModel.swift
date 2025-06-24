//
//  ImageEditorModel.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/16.
//

import UIKit

protocol ImageEditorModelObserver: AnyObject {
    func imageEditorModelDidChange(changedItemIds: [String])
    func imageEditorModelDidChange(before: ImageEditorContents, after: ImageEditorContents)
}


final class ImageEditorModel {
    
    let srcImageSizePixels: CGSize
    
    let srcImage: UIImage
    
    private var contents: ImageEditorContents
    
    private var transform: ImageEditorTransform
    
    var blurredSourceImage: CGImage?
    
    init(image: UIImage) {
        self.srcImageSizePixels = image.size
        self.srcImage = image
        self.contents = ImageEditorContents()
        self.transform = ImageEditorTransform.defaultTransform(srcImageSizePixels: image.size)
    }
    
    // MARK: - Observers
    private var observers: NSHashTable<AnyObject> = .weakObjects()
    
    func addObserver(observer: ImageEditorModelObserver) {
        observers.add(observer)
    }
    
    private func fireModelDidChange(changeItemIds: [String]) {
        
        observers.allObjects
            .compactMap { $0 as? ImageEditorModelObserver }
            .forEach { weakObject in
                weakObject.imageEditorModelDidChange(changedItemIds: changeItemIds)
            }
    }
    
    private func fireModelDidChange(before: ImageEditorContents, after: ImageEditorContents) {
        // We could diff here and yield a more narrow change event.
        observers.allObjects
            .compactMap { $0 as? ImageEditorModelObserver }
            .forEach { weakObject in
                weakObject.imageEditorModelDidChange(before: before, after: after)
            }
    }
    
    private func performAction(_ action: (ImageEditorContents) -> ImageEditorContents, changedItemIds: [String]?) {
        
        let oldContents = self.contents
        let newContents = action(oldContents)
        contents = newContents

        if let changedItemIds = changedItemIds {
            fireModelDidChange(changeItemIds: changedItemIds)
        } else {
            fireModelDidChange(before: oldContents, after: self.contents)
        }
    }
}

extension ImageEditorModel {
    
    func remove(item: ImageEditorItem) {
        performAction({ (oldContents) in
            let newContents = oldContents.clone()
            newContents.remove(item: item)
            return newContents
        }, changedItemIds: [item.itemId])
    }
    
    func append(item: ImageEditorItem) {
        performAction({ (oldContents) in
            let newContents = oldContents.clone()
            newContents.append(item: item)
            return newContents
        }, changedItemIds: [item.itemId])
    }
    
    func replace(item: ImageEditorItem) {
        performAction({ (oldContents) in
            let newContents = oldContents.clone()
            newContents.replace(item: item)
            return newContents
        }, changedItemIds: [item.itemId])
    }
}

extension ImageEditorModel {
    
    func currentTransform() -> ImageEditorTransform {
        transform
    }
    
    func itemCount() -> Int {
        return contents.itemCount()
    }

    func items() -> [ImageEditorItem] {
        return contents.items()
    }
    
    func itemIds() -> [String] {
        return contents.itemIds()
    }

    func has(itemForId itemId: String) -> Bool {
        return item(forId: itemId) != nil
    }

    func item(forId itemId: String) -> ImageEditorItem? {
        return contents.item(forId: itemId)
    }
}
