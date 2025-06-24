//
//  IEAssertionError.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/24.
//

import Foundation

struct IEAssertionError: Error {
    
    let description: String
    init(
        _ description: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        debugPrint("assertionError: \(description)", file, function, line)
        self.description = description
    }
}

// An error that won't assert.
struct IEGenericError: Error {
    let description: String
    init(_ description: String) {
        self.description = description
    }
}
