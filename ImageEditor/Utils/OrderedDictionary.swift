//
//  OrderedDictionary.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/16.
//

import Foundation

public struct OrderedDictionary<KeyType: Hashable, ValueType> {

    private var keyValueMap = [KeyType: ValueType]()

    public private(set) var orderedKeys = [KeyType]()

    public init() { }

    public init(keyValueMap: [KeyType: ValueType], orderedKeys: [KeyType]) {
        ieAssertDebug(keyValueMap.count == orderedKeys.count)
        ieAssertDebug(Set(orderedKeys) == Set(keyValueMap.keys), "Invalid contents.")

        self.keyValueMap = keyValueMap
        self.orderedKeys = orderedKeys
    }

    public subscript(key: KeyType) -> ValueType? {
        return keyValueMap[key]
    }

    public func hasValue(forKey key: KeyType) -> Bool {
        return keyValueMap[key] != nil
    }

    public mutating func insert(key: KeyType, at index: Int, value: ValueType) {
        iePrecondition(keyValueMap[key] == nil, "Key already in dictionary: \(key)")
        ieAssertDebug(!orderedKeys.contains(key), "Unexpected duplicate key in key list: \(key)")

        keyValueMap[key] = value
        orderedKeys.insert(key, at: index)

        ieAssertDebug(orderedKeys.count == keyValueMap.count, "Invalid contents.")
    }

    public mutating func append(key: KeyType, value: ValueType) {
        insert(key: key, at: count, value: value)
    }

    public mutating func prepend(key: KeyType, value: ValueType) {
        insert(key: key, at: 0, value: value)
    }

    @discardableResult
    public mutating func replace(key: KeyType, value: ValueType) -> ValueType {
        guard let oldValue = keyValueMap.updateValue(value, forKey: key) else {
            ieFail("Key is not present in OrderedDictionary: \(key)")
        }

        ieAssertDebug(orderedKeys.contains(key), "Missing key in key list: \(key)")
        ieAssertDebug(orderedKeys.count == keyValueMap.count, "Invalid contents.")

        return oldValue
    }

    @discardableResult
    public mutating func remove(key: KeyType) -> ValueType? {
        guard let value = keyValueMap.removeValue(forKey: key) else {
            return nil
        }

        ieAssertDebug(orderedKeys.contains(key), "Missing key in key list: \(key)")
        orderedKeys.removeAll { $0 == key }

        ieAssertDebug(orderedKeys.count == keyValueMap.count, "Invalid contents.")
        return value
    }

    public mutating func remove(at index: Int) {
        let key = orderedKeys[index]
        guard keyValueMap.removeValue(forKey: key) != nil else {
            ieFailDebug("Missing key in dictionary: \(key)")
            return
        }
        orderedKeys.remove(at: index)
    }

    public mutating func removeSubrange<R: RangeExpression>(_ range: R) where R.Bound == Int {
        orderedKeys[range].forEach { key in
            guard keyValueMap.removeValue(forKey: key) != nil else {
                ieFailDebug("Missing key in dictionary: \(key)")
                return
            }
        }
        orderedKeys.removeSubrange(range)
    }

    public mutating func removeAll() {
        keyValueMap.removeAll()
        orderedKeys.removeAll()
    }

    public mutating func moveExistingKeyToFirst(_ key: KeyType) {
        guard let index = orderedKeys.firstIndex(of: key) else {
            ieFail("Key not in dictionary: \(key)")
        }

        orderedKeys.remove(at: index)
        orderedKeys.insert(key, at: 0)
    }

    public var orderedValues: [ValueType] {
        return self.map { $0.value }
    }

    public var firstKey: KeyType? {
        orderedKeys.first
    }

    public var lastKey: KeyType? {
        orderedKeys.last
    }
}

// MARK: -

extension OrderedDictionary: RandomAccessCollection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { self.orderedKeys.count }

    public subscript(position: Int) -> (key: KeyType, value: ValueType) {
        iePrecondition(indices.contains(position))
        let key = orderedKeys[position]
        guard let value = keyValueMap[key] else {
            ieFail("Missing value")
        }
        return (key: key, value: value)
    }
}

// MARK: -

extension OrderedDictionary: Encodable where KeyType: Encodable, ValueType: Encodable {}
extension OrderedDictionary: Decodable where KeyType: Decodable, ValueType: Decodable {}

// MARK: - Sequence

extension OrderedDictionary: Sequence {
    public typealias IteratorTuple = (key: KeyType, value: ValueType)
    public typealias Iterator = AnyIterator<IteratorTuple>

    public func makeIterator() -> Iterator {
        let keyValueMap = self.keyValueMap
        var keyIterator = orderedKeys.makeIterator()
        return Iterator { () -> IteratorTuple? in
            guard let key = keyIterator.next() else {
                return nil
            }
            guard let value = keyValueMap[key] else {
                return nil
            }
            return (key: key, value: value)
        }
    }
}
