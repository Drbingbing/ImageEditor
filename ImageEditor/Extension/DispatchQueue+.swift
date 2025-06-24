//
//  DispatchQueue+.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/24.
//

import Foundation

extension DispatchQueue {
    
    static let sharedUserInteractive: DispatchQueue = {
        return DispatchQueue(label: "org.imageEditor.serial-user-interactive",
                             qos: .userInteractive,
                             autoreleaseFrequency: .workItem)
    }()
}
