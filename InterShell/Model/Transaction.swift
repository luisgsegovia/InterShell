//
//  Transaction.swift
//  InterShell
//
//  Created by Luis Segovia on 09/03/23.
//

import Foundation

struct Transaction {
    var store: [String: String] = [:]
    var keysToBeDeleted: Set<String> = []

    mutating func append(_ register: Register) {
        store[register.key] = register.value
    }

    mutating func append(keyToBeDeleted key: String) {
        keysToBeDeleted.insert(key)
    }
}
