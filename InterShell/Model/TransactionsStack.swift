//
//  TransactionsStack.swift
//  InterShell
//
//  Created by Luis Segovia on 09/03/23.
//

import Foundation

protocol TransactionsStackProtocol {
    var stack: Stack<Transaction> { get set }

    mutating func push(_ transaction: Transaction)
    mutating func pop() -> Transaction?
    mutating func set(_ register: (key: String, value: String), completion: @escaping (StackInsertionResult) -> Void)
    mutating func get(by key: String, completion: @escaping (StackRetrievalResult) -> Void)
    mutating func delete(key: String, completion: @escaping (StackDeletionResult) -> Void)
    mutating func count(of value: String, completion: @escaping (StackValueCountResult) -> Void)
    mutating func begin()
    mutating func commit(completion: @escaping (StackCommitResult) -> Void)
    mutating func rollback(completion: @escaping (StackRollbackResult) -> Void)
    func transactionsCount() -> Int
    func hasActiveTransaction() -> Bool
}

struct TransactionsStack: TransactionsStackProtocol {
    var stack = Stack<Transaction>()
    private var storageManager: StorageManageable

    init(storageManager: StorageManageable = StorageManager()) {
        self.storageManager = storageManager
    }

    mutating func push(_ transaction: Transaction) {
        stack.push(transaction)
    }

    @discardableResult
    mutating func pop() -> Transaction? {
        return stack.pop()
    }

    mutating func set(_ register: (key: String, value: String), completion: @escaping (StackInsertionResult) -> Void) {
        if var currentTransaction = stack.pop() {
            currentTransaction.append(register)
            stack.push(currentTransaction)
            completion(.success(register.value))
        } else {
            // User is not in a transaction. Insert in global storage
            storageManager.save(register: register) { result in
                switch result {
                case .success(let insertedValue):
                    completion(.success(insertedValue))
                case .failure:
                    completion(.failure(.insertionError))
                }
            }
        }
    }

    mutating func get(by key: String, completion: @escaping (StackRetrievalResult) -> Void) {
        // User is in an active transaction. Perform search first in local storage.
        if let currentTransaction = stack.peek() {

            // Scenario: User previously requested a key to be deleted inside the transaction,
            // so UI should reply that the given key was not found/set, even if the key/value pair
            // is in the global storage, because the current transaction has not been commited yet.
            // If the user rollbacks the transaction and executes the same `get` operation,
            // the scenario would to be look up normally in the following order:
            // First in the local current transaction storage, then in the transactions stacks (because of nesting), and finally in the global storage.
            let keyWillBeDeleted = currentTransaction.keysToBeDeleted.contains(key)
            if keyWillBeDeleted {
                completion(.failure(.noKeyFound))
                return
            }

            // Look up first locally for the given transaction.
            if let value = currentTransaction.store[key] {
                completion(.success(value))
            } else if let value = traverseStack(lookingForKey: key) {
                // Look up in nested transactions
                completion(.success(value))
            } else {
                retrieve(by: key, completion: completion)
            }
        } else {
            // User is not currently in a transaction. Look up in global storage.
            retrieve(by: key, completion: completion)
        }
    }

    mutating func delete(key: String, completion: @escaping (StackDeletionResult) -> Void) {
        // if it previously existed before commiting
        if var currentTransaction = stack.pop() {
            if let deletedValue = currentTransaction.store.removeValue(forKey: key) {
                // Save the desired key to be deleted, to apply changes in global storage when commit happens
                currentTransaction.keysToBeDeleted.insert(key)
                stack.push(currentTransaction)
                completion(.success(deletedValue))

                //TODO: What happens if user wants to delete a key from parent transaction?
            } else {
                currentTransaction.keysToBeDeleted.insert(key)
                stack.push(currentTransaction)
                completion(.failure(.noKeyFound))
            }
        } else {
            // User is not in a transaction, perform deletion in global storage
            storageManager.delete(by: key) { result in
                switch result {
                case .success(let deletedValue):
                    completion(.success(deletedValue))
                case .failure(let error):
                    switch error {
                    case .keyNotFound:
                        completion(.failure(.noKeyFound))
                    case .deletionError:
                        completion(.failure(.deletionError))
                    }
                }
            }
        }
    }

    mutating func count(of value: String, completion: @escaping (StackValueCountResult) -> Void) {
        var count = 0

        // Check current and parent transactions
        count += traverseStack(toCount: value)

        // Finally search in global storage
        storageManager.count(ofValue: value) { result in
            switch result {
            case .success(let storageCount):
                count += storageCount
            case .failure(_):
                completion(.failure(.operationError))
            }
        }

        completion(.success(count))
    }

    mutating func begin() {
        stack.push(Transaction())

    }

    mutating func commit(completion: @escaping (StackCommitResult) -> Void) {
        guard let currentTransaction = pop() else {
            completion(.failure(.noActiveTransaction))
            return
        }

        currentTransaction.store.forEach { key, value in
            storageManager.save(register: (key, value)) { _ in }
        }

        // Delete any keys requested to be deleted by user
        currentTransaction.keysToBeDeleted.forEach { key in
            storageManager.delete(by: key) { _ in }
        }

        completion(.success)
    }

    mutating func rollback(completion: @escaping (StackRollbackResult) -> Void) {
        guard let _ = pop() else {
            completion(.failure(.noActiveTransaction))
            return
        }

        completion(.success)
    }

    func transactionsCount() -> Int {
        return stack.count()
    }

    func hasActiveTransaction() -> Bool {
        guard stack.peek() != nil else { return false }
        return true
    }
}

// MARK: - Helper functions

private extension TransactionsStack {
    mutating func traverseStack(lookingForKey key: String) -> String? {
        var temporalStack = Stack<Transaction>()
        var value: String? = nil

        while let transaction = pop() {
            temporalStack.push(transaction)
            if let foundValue = transaction.store[key] {
                value = foundValue
                restoreStack(from: &temporalStack)

                return value
            }
        }

        restoreStack(from: &temporalStack)

        return value
    }

    mutating func traverseStack(toCount value: String) -> Int {
        var temporalStack = Stack<Transaction>()
        var count = 0

        while let transaction = pop() {
            temporalStack.push(transaction)
            count += transaction.store.values.filter { value == $0 }.count
        }

        restoreStack(from: &temporalStack)

        return count
    }

    mutating func restoreStack(from temporalStack: inout Stack<Transaction>) {
        while temporalStack.peek() != nil {
            if let originalTransaction = temporalStack.pop() {
                stack.push(originalTransaction)
            }
        }
    }

    func retrieve(by key: String, completion: @escaping (StackRetrievalResult) -> Void) {
        storageManager.retrieve(by: key) { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                switch error {
                case .keyNotFound:
                    completion(.failure(.noKeyFound))
                case .retrievalError:
                    completion(.failure(.retrievalError))
                }
            }
        }
    }
}
