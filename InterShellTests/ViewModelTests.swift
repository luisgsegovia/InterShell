//
//  ViewModelTests.swift
//  InterShellTests
//
//  Created by Luis Segovia on 16/03/23.
//

import XCTest
@testable import InterShell

final class ViewModelTests: XCTestCase {

    private let mockValue = "A mocked value"

    func test_executeSetCommandReturnsExpectedOutput() {
        let sut = createSUT()
        let key = "A key"
        let value = "A value"

        sut.key = key
        sut.value = value

        XCTAssertTrue(sut.fieldsHaveValues.wrappedValue)

        sut.execute(command: .set((key, value)))
        
        XCTAssertFalse(sut.fieldsHaveValues.wrappedValue)
        XCTAssertEqual("> SET \(key) \(value)", sut.commandsOutput.last)
    }

    func test_executeGetCommandReturnsExpectedOutput() {
        let sut = createSUT()
        let key = "A key"

        sut.key = key
        sut.execute(command: .get(key: key))

        let commandOutput = sut.commandsOutput.removeLast()
        XCTAssertEqual(mockValue, commandOutput)
        XCTAssertEqual("> GET \(key)", sut.commandsOutput.last)
    }

    func test_executeDeleteCommandReturnsExpectedOutput() {
        let sut = createSUT()
        let key = "A key"

        sut.execute(command: .delete(key: key))

        XCTAssertEqual("Deleted value: \(mockValue)", sut.commandsOutput.last)
    }

    func test_executeBeginCommandContinues() {
        let sut = createSUT()

        sut.execute(command: .begin)

        XCTAssertEqual(1, sut.commandsOutput.count)
    }

    func test_executeCommitCommandReturnsExpectedOutput() {
        let sut = createSUT()

        sut.execute(command: .commit)

        XCTAssertEqual("Commit successful", sut.commandsOutput.last)
    }

    func test_executeCommitCommandReturnsExpectedErrorOutput() {
        let sut = createSUT(isFailure: true)

        sut.execute(command: .commit)

        XCTAssertEqual("no transaction", sut.commandsOutput.last)
    }


    func test_executeRollbackCommandReturnsExpectedOutput() {
        let sut = createSUT()

        sut.execute(command: .rollback)

        XCTAssertEqual("Rollback successful", sut.commandsOutput.last)
    }

    func test_executeRollbackCommandReturnsExpectedErrorOutput() {
        let sut = createSUT(isFailure: true)

        sut.execute(command: .rollback)

        XCTAssertEqual("no transaction", sut.commandsOutput.last)
    }

    func test_executeCountCommandReturnsExpectedOutput() {
        let sut = createSUT()

        sut.execute(command: .count(value: mockValue))

        let commandOutput = sut.commandsOutput.removeLast()
        XCTAssertEqual("0", commandOutput)
        XCTAssertEqual("> COUNT \(mockValue)", sut.commandsOutput.last)
    }

    private func createSUT(isFailure: Bool = false) -> ViewModel {
        var mock = TransactionsStackMock()
        mock.isFailure = isFailure
        return ViewModel(transactionsStack: mock)
    }
}

struct TransactionsStackMock: TransactionsStackProtocol {
    var isFailure = false
    var stack: InterShell.Stack<InterShell.Transaction> = Stack<Transaction>()
    private let mockValue = "A mocked value"

    mutating func push(_ transaction: InterShell.Transaction) {
    }

    mutating func pop() -> InterShell.Transaction? {
        return nil
    }

    mutating func set(_ register: (key: String, value: String), completion: @escaping (InterShell.StackInsertionResult) -> Void) {
        guard !isFailure else {
            completion(.failure(.insertionError))
            return
        }
        completion(.success(register.value))
    }

    mutating func get(by key: String, completion: @escaping (InterShell.StackRetrievalResult) -> Void) {
        guard !isFailure else {
            completion(.failure(.noKeyFound))
            return
        }
        completion(.success(mockValue))
    }

    mutating func delete(key: String, completion: @escaping (InterShell.StackDeletionResult) -> Void) {
        guard !isFailure else {
            completion(.failure(.noKeyFound))
            return
        }
        completion(.success(mockValue))
    }

    mutating func count(of value: String, completion: @escaping (InterShell.StackValueCountResult) -> Void) {
        completion(.success(0))
    }

    mutating func begin() {
    }

    mutating func commit(completion: @escaping (InterShell.StackCommitResult) -> Void) {
        guard !isFailure else {
            completion(.failure(.noActiveTransaction))
            return
        }
        completion(.success)
    }

    mutating func rollback(completion: @escaping (InterShell.StackRollbackResult) -> Void) {
        guard !isFailure else {
            completion(.failure(.noActiveTransaction))
            return
        }
        completion(.success)
    }

    func transactionsCount() -> Int {
        0
    }

    func hasActiveTransaction() -> Bool {
        true
    }


}
