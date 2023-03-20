//
//  TransactionStackTests.swift
//  InterShellTests
//
//  Created by Luis Segovia on 09/03/23.
//

import Foundation
import XCTest
@testable import InterShell

class TransactionStackTests: XCTestCase {
    func test_insertionOnNoCurrentTransactionIsSuccessful() {
        let exp = expectation(description: "Wait for count operation")
        let key = "A key"
        let expectedValue = "A value"
        var sut = createSUT()

        sut.set((key, expectedValue)) { result in
            switch result {
            case .success(let insertedValue):
                XCTAssertEqual(insertedValue, expectedValue)
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value inserted.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }


    func test_insertionOnCurrentTransactionIsSuccessful() {
        let exp = expectation(description: "Wait for count operation")
        let key = "A key"
        let expectedValue = "A value"
        var sut = createSUT()

        sut.begin()

        sut.set((key, expectedValue)) { result in
            switch result {
            case .success(let insertedValue):
                XCTAssertEqual(insertedValue, expectedValue)
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value inserted.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrievalOfValueOnCurrentTransactionIsSuccessful() {
        let exp = expectation(description: "Wait for retrieval operation")
        let key = "A key"
        let expectedValue = "A value"
        var sut = createSUT()

        sut.begin()

        sut.set((key, expectedValue)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value inserted.")
                exp.fulfill()
            }

        }

        sut.get(by: key) { result in
            switch result {
            case .success(let retrievedValue):
                XCTAssertEqual(retrievedValue, expectedValue)
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value retrieved.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrievalOfValueOnNoCurrentTransactionIsSuccessful() {
        let exp = expectation(description: "Wait for retrieval operation")
        let key = "A key"
        let expectedValue = "A value"
        var sut = createSUT()

        sut.set((key, expectedValue)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value inserted.")
                exp.fulfill()
            }

        }

        sut.get(by: key) { result in
            switch result {
            case .success(let retrievedValue):
                XCTAssertEqual(retrievedValue, expectedValue)
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value retrieved.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrievalOfValueForNonFoundKeyOnCurrentTransactionFails() {
        let exp = expectation(description: "Wait for count operation")
        let key = "A key"
        let anotherKey = "Another key"
        let value = "A value"
        var sut = createSUT()

        sut.begin()

        sut.set((key, value)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(value) value inserted.")
                exp.fulfill()
            }

        }

        sut.get(by: anotherKey) { result in
            switch result {
            case .success:
                XCTFail("Something went wrong. Expected failure for none key found.")
            case .failure(let error):
                XCTAssertEqual([error], [StackRetrievalError.noKeyFound])
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrievalOfValueForNonFoundKeyOnNonCurrentTransactionFails() {
        let exp = expectation(description: "Wait for retrieval operation")
        let key = "A key"
        let anotherKey = "Another key"
        let value = "A value"
        var sut = createSUT()

        sut.set((key, value)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(value) value inserted.")
                exp.fulfill()
            }
        }

        sut.get(by: anotherKey) { result in
            switch result {
            case .success:
                XCTFail("Something went wrong. Expected failure for none key found.")
            case .failure(let error):
                XCTAssertEqual([error], [StackRetrievalError.noKeyFound])
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_deleteRemovesGivenKeyOnNoCurrentTrasactionSucessfully() {
        let exp = expectation(description: "Wait for deletion operation")
        let key = "A key"
        let expectedValue = "A value"
        var sut = createSUT()

        sut.set((key, expectedValue)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value inserted.")
                exp.fulfill()
            }
        }

        sut.delete(key: key) { result in
            switch result {
            case .success(let deletedValue):
                XCTAssertEqual(deletedValue, expectedValue)
            case .failure:
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value deleted.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_deleteRemovesGivenKeyOnCurrentTrasactionSucessfully() {
        let exp = expectation(description: "Wait for deletion operation")
        let key = "A key"
        let expectedValue = "A value"
        var sut = createSUT()

        sut.begin()

        sut.set((key, expectedValue)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value inserted.")
                exp.fulfill()
            }
        }

        sut.delete(key: key) { result in
            switch result {
            case .success(let deletedValue):
                XCTAssertEqual(deletedValue, expectedValue)
            case .failure:
                XCTFail("Something went wrong. Expected success path with \(expectedValue) value deleted.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_deleteFailsRemovingGivenKeyOnCurrentTrasactionAndNoKeyFound() {
        let exp = expectation(description: "Wait for deletion operation")
        let key = "A key"
        let anotherKey = "Another key"
        let value = "A value"
        var sut = createSUT()

        sut.begin()

        sut.set((key, value)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(value) value inserted.")
                exp.fulfill()
            }
        }

        sut.delete(key: anotherKey) { result in
            switch result {
            case .success:
                XCTFail("Something went wrong. Expected failure path with \(key) value not found.")
            case .failure(let error):
                XCTAssertEqual([StackDeletionError.noKeyFound], [error])
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_deleteFailsRemovingGivenKeyOnNoCurrentTrasactionAndNoKeyFound() {
        let exp = expectation(description: "Wait for deletion operation")
        let key = "A key"
        let anotherKey = "Another key"
        let value = "A value"
        var sut = createSUT()

        sut.set((key, value)) { result in
            switch result {
            case .success:
                break
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(value) value inserted.")
                exp.fulfill()
            }
        }

        sut.delete(key: anotherKey) { result in
            switch result {
            case .success:
                XCTFail("Something went wrong. Expected failure path with \(key) value not found.")
            case .failure(let error):
                XCTAssertEqual([StackDeletionError.noKeyFound], [error])
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }


    func test_countOfValueDeliversZeroOnEmptyTransactionsAndEmptyStorage() {
        let exp = expectation(description: "Wait for count operation")
        let expectedCount = 0
        var sut = createSUT()

        sut.count(of: "Any value") { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, expectedCount)
            case .failure(_):
                XCTFail("Something went wrong. Expected success path with \(expectedCount) count value")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_beginFunctionCreatesNewUniqueTransaction() {
        var sut = createSUT()

        sut.begin()

        let transaction = sut.pop()
        XCTAssertNotNil(transaction)

        let nilTransaction = sut.pop()
        XCTAssertNil(nilTransaction)
    }

    func test_beginFunctionCalledThreeTimesCreatesNewUniqueTransactions() {
        var sut = createSUT()

        sut.begin()
        sut.begin()
        sut.begin()

        let transaction = sut.pop()
        XCTAssertNotNil(transaction)

        sut.pop()
        sut.pop()

        let nilTransaction = sut.pop()
        XCTAssertNil(nilTransaction)
    }

    func test_rollbackOperationDeletesCurrentTransaction() {
        let exp = expectation(description: "Wait for rollback operaton")
        let key = "A key"
        let value = "A value"
        var sut = createSUT()

        sut.begin()

        sut.set((key, value)) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Something went wrong. Expected success path with \(value) value inserted")
                exp.fulfill()
            }
        }

        var transaction = sut.pop()

        XCTAssertEqual(transaction?.store.isEmpty, false, "Expected transaction store to not be empty")

        sut.push(transaction!)

        sut.rollback() { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Something went wrong. Expected rollback success path")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        transaction = sut.pop()

        XCTAssertEqual(sut.transactionsCount(), 0, "Expected transaction stack to be empty")
    }

    func test_rollbackOperationReturnsErrorOnNoActiveTransaction() {
        let exp = expectation(description: "Wait for rollback operaton")
        var sut = createSUT()

        sut.rollback { result in
            switch result {
            case .success():
                XCTFail("Expected rollback failure path, as there's no active transaction")
            case .failure(let error):
                XCTAssertEqual([StackRollbackError.noActiveTransaction], [error])
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_lookforValueInNestedTransactionsAndFoundsItSuccessfullyInSecondNestedTransaction() {
        let exp = expectation(description: "Wait for rollback operaton")
        var sut = createSUT()
        let peakKey = "A peak key"
        let peakValue = "A peak value"
        let toBeFoundKey = "Key to be found"
        let toBeFoundValue  = "You found the key"

        sut.set(("A first Key", "Value of first key")) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                XCTFail("Expected insertion success path")
            }
        }

        sut.begin()
        sut.begin()

        sut.set((toBeFoundKey, toBeFoundValue)) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                XCTFail("Expected insertion success path")
            }
        }

        sut.begin()

        sut.set((peakKey, peakValue)) { result in
            switch result {
            case .success:
                break
            case.failure:
                XCTFail("Expected insertion success path")
            }
        }

        sut.get(by: toBeFoundKey) { result in
            switch result {
            case .success(let foundValue):
                XCTAssertEqual(foundValue, toBeFoundValue)
            case .failure(_):
                XCTFail("Expected retrieval success path")
            }
        }

        // Ensure the order of the transactions wasn't lost after performing the traversal searching
        sut.get(by: peakKey) { result in
            switch result {
            case .success(let foundValue):
                XCTAssertEqual(foundValue, peakValue)
                exp.fulfill()
            case .failure(_):
                XCTFail("Expected retrieval success path")
            }
        }
        
        XCTAssertEqual(3, sut.transactionsCount())

        wait(for: [exp], timeout: 1.0)
    }

    func test_countForValueInNestedTransactionsReturnCorrectCountSuccessully() {
        let exp = expectation(description: "Wait for count operaton")
        var sut = createSUT()
        let toBeCountValue = "100"
        let expectedTotalCount = 3

        sut.set(("First key", toBeCountValue)) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                XCTFail("Expected insertion success path")
            }
        }

        sut.begin()

        sut.set(("Second key", toBeCountValue)) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                XCTFail("Expected insertion success path")
            }
        }

        sut.begin()

        sut.set(("Third key", toBeCountValue)) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                XCTFail("Expected insertion success path")
            }
        }

        sut.count(of: toBeCountValue) { result in
            switch result {
            case .success(let countValue):
                XCTAssertEqual(countValue, expectedTotalCount)
                exp.fulfill()
            case .failure(_):
                XCTFail("Expected a count value in success path")
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func createSUT() -> TransactionsStack {
        return TransactionsStack(storageManager: StorageManager())
    }
}
