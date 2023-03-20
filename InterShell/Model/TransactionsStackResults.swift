//
//  TransactionsStackResults.swift
//  InterShell
//
//  Created by Luis Segovia on 10/03/23.
//

import Foundation

typealias StackRetrievalResult = Result<String, StackRetrievalError>
typealias StackInsertionResult = Result<String, StackInsertionError>
typealias StackDeletionResult = Result<String, StackDeletionError>
typealias StackValueCountResult = Result<Int, StackValueCountError>
typealias StackCommitResult = Result<Void, StackCommitError>
typealias StackRollbackResult = Result<Void, StackRollbackError>

enum StackRetrievalError: Error {
    case noKeyFound
    case retrievalError
}

enum StackInsertionError: Error {
    case insertionError
}

enum StackDeletionError: Error {
    case noKeyFound
    case deletionError
}

enum StackValueCountError: Error {
    case operationError
}

enum StackCommitError: Error {
    case noActiveTransaction
}

enum StackRollbackError: Error {
    case noActiveTransaction
}


public extension Result where Success == Void {
    /// A success, storing a Success value.
    ///
    /// Instead of `.success(())`, now  `.success` can be used
    static var success: Result {
        return .success(())
    }
}
