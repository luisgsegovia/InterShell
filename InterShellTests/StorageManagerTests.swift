//
//  StoreManagerTests.swift
//  InterShellTests
//
//  Created by Luis Segovia on 09/03/23.
//

import Foundation
import XCTest
@testable import InterShell

class StoreManagerTests: XCTestCase {
    func test_saveSuccessfullyInsertsToStorage() {
        let exp = expectation(description: "Wait for insertion")
        let sut = StorageManager()
        let expectedValue = "A value"

        sut.save(register: ("Hello", expectedValue)) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value, expectedValue)
            case .failure(_):
                XCTFail("Something went wrong. Expected to insert \(expectedValue) value.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveSuccessfullyRetrievesRequestedKey() {
        let exp = expectation(description: "Wait for value retrieval")
        let sut = StorageManager()
        let key = "A key"
        let expectedValue = "A value inserted and then retrieved"

        sut.save(register: (key, expectedValue)) { _ in }
        sut.retrieve(by: key) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value, expectedValue)
            case .failure(_):
                XCTFail("Something went wrong. Expected to retrieve \(expectedValue) value.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveFailsOnNonFoundKey() {
        let exp = expectation(description: "Wait for deletion")
        let sut = StorageManager()
        let key = "A key"

        sut.retrieve(by: key) { result in
            switch result {
            case .success:
                XCTFail("Something went wrong. Expected to fail on retrieval due to no found key")
            case .failure(let error):
                XCTAssertEqual([error], [RetrievalError.keyNotFound])
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_deleteSuccesfullyDeletesRegisterByGivenKey() {
        let exp = expectation(description: "Wait for deletion")
        let sut = StorageManager()
        let key = "A key"
        let expectedValue = "A value inserted and then deleted"

        sut.save(register: (key, expectedValue)) { _ in }
        sut.delete(by: key) { result in
            switch result {
            case .success(let deletedValue):
                XCTAssertEqual(deletedValue, expectedValue)
            case .failure(_):
                XCTFail("Something went wrong. Expected to delete \(expectedValue) value.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_deleteFailsOnNonFoundKey() {
        let exp = expectation(description: "Wait for deletion")
        let sut = StorageManager()
        let key = "A key"

        sut.delete(by: key) { result in
            switch result {
            case .success:
                XCTFail("Something went wrong. Expected to fail on deletion due to no found key")
            case .failure(let error):
                XCTAssertEqual([error], [DeletionError.keyNotFound])
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_countOfValueReturnsZeroOnEmptyStorage() {
        let exp = expectation(description: "Wait for count operation")
        let sut = StorageManager()
        let value = "A value"
        let expectedCount = 0

        sut.count(ofValue: value) { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, expectedCount)
            case .failure:
                XCTFail("Something went wrong. Expected success path with \(expectedCount) count value")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_countOfValueReturnsZeroOnNonFoundValue() {
        let exp = expectation(description: "Wait for count operation")
        let sut = StorageManager()
        let key = "A key"
        let value = "A value"
        let anotherValue = "Another value"
        let expectedCount = 0

        sut.save(register: (key, value)) { result in
            switch result {
            case .failure:
                XCTFail("Something went wrong. Expected a successful register insertion")
                exp.fulfill()
            case .success:
                break
            }
        }

        sut.count(ofValue: anotherValue) { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, expectedCount)
            case .failure:
                XCTFail("Something went wrong. Expected success path with \(expectedCount) count value")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_countOfValueReturnsOneOnFoundValue() {
        let exp = expectation(description: "Wait for count operation")
        let sut = StorageManager()
        let key = "A key"
        let value = "A value"
        let expectedCount = 1

        sut.save(register: (key, value)) { result in
            switch result {
            case .failure:
                XCTFail("Something went wrong. Expected a successful register insertion")
                exp.fulfill()
            case .success:
                break
            }
        }

        sut.count(ofValue: value) { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, expectedCount)
            case .failure:
                XCTFail("Something went wrong. Expected success path with \(expectedCount) count value")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
