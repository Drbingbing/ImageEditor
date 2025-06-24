//
//  SwiftAssertUtils.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/17.
//

import Foundation

/// Synchronize access to state in this class using this queue.
func assertOnQueue(_ queue: DispatchQueue) {
    dispatchPrecondition(condition: .onQueue(queue))
}

@inlinable
func assertIsOnMainThread() {
    if !Thread.isMainThread {
        ieFailDebug("Must be on main thread")
    }
}

@inlinable
func assertIsNotOnMainThread() {
    if Thread.isMainThread {
        ieFailDebug("Must be off main thread")
    }
}

@inlinable
func ieFailDebug(_ logMessage: String) {
    assertionFailure(logMessage)
}

@inlinable
func ieFail(_ logMessage: String) -> Never {
    fatalError(logMessage)
}

func failIfThrows<T>(block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        ieFail("Couldn't write: \(error)")
    }
}

@inlinable
func ieAssertDebug(_ condition: Bool, _ message: @autoclosure () -> String = String()) {
    if !condition {
        let message = message()
        ieFailDebug(message.isEmpty ? "Assertion failed" : message)
    }
}

@inlinable
func iePrecondition(_ condition: Bool, _ message: @autoclosure () -> String = String()) {
    if !condition {
        let message = message()
        ieFail(message.isEmpty ? "Assertion failed" : message)
    }
}
