//
//  WithoutDeprecationWarnings.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/12.
//

@inline(__always)
func withoutDeprecationWarnings(_ block: () -> Void) {
    block()
}
