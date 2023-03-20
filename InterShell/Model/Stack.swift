//
//  Stack.swift
//  InterShell
//
//  Created by Luis Segovia on 09/03/23.
//

import Foundation

public struct Stack<T> {
    var items: [T] = []

    mutating func push(_ item: T) {
        self.items.insert(item, at: .zero)
    }

    @discardableResult
    mutating func pop() -> T? {
        if items.isEmpty { return nil }
        return self.items.removeFirst()
    }

    func peek() -> T? {
        return self.items.first
    }

    func count() -> Int {
        items.count
    }
}

