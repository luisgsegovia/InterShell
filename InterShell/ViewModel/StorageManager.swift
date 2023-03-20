//
//  StorageManager.swift
//  InterShell
//
//  Created by Luis Segovia on 09/03/23.
//

import Foundation
import Combine

typealias InsertionResult = Result<String, InsertionError>
typealias RetrievalResult = Result<String, RetrievalError>
typealias DeletionResult = Result<String, DeletionError>
typealias CountResult = Result<Int, CountError>

enum InsertionError: Error {
    case insertionError
}

enum RetrievalError: Error {
    case keyNotFound
    case retrievalError
}

enum DeletionError: Error {
    case keyNotFound
    case deletionError
}

enum CountError: Error {
    case operationError
}

protocol StorageManageable: AnyObject {
    func save(register: (key: String, value: String), completion: @escaping (InsertionResult) -> Void)
    func retrieve(by: String, completion: @escaping (RetrievalResult) -> Void)
    func delete(by: String, completion: @escaping (DeletionResult) -> Void)
    func count(ofValue value: String, completion: @escaping (CountResult) -> Void)
}

class StorageManager: StorageManageable {
    // Main storage
    private var storage: [String: String] = [:]

    func save(register: (key: String, value: String), completion: @escaping (InsertionResult) -> Void) {
        storage[register.key] = register.value
        completion(.success(register.value))
    }

    func save(register: (key: String, value: String)) -> Future<InsertionResult, Never> {
        return Future() { promise in
            self.storage[register.key] = register.value
            promise(.success(.success(register.value)))
        }
    }

    func retrieve(by key: String, completion: @escaping (RetrievalResult) -> Void) {
        let foundValue = storage[key]

        switch foundValue {
        case .some(let value):
            completion(.success(value))
        case .none:
            completion(.failure(.keyNotFound))
        }
    }

    func delete(by key: String, completion: @escaping (DeletionResult) -> Void) {
        let removedValue = storage.removeValue(forKey: key)

        switch removedValue {
        case .some(let value):
            completion(.success(value))
        case .none:
            completion(.failure(.keyNotFound))
        }
    }

    func count(ofValue value: String, completion: @escaping (CountResult) -> Void) {
        let ocurrences = storage.values.filter { $0 == value }.count
        completion(.success(ocurrences))
    }
}
