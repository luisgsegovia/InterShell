//
//  ViewModel.swift
//  InterShell
//
//  Created by Luis Segovia on 10/03/23.
//

import Foundation
import SwiftUI

typealias Register = (key: String, value: String)

enum Command {

    case set(Register)
    case get(key: String)
    case delete(key: String)
    case count(value: String)
    case begin
    case commit
    case rollback
}

class ViewModel: ObservableObject {
    @Published var key: String = .empty
    @Published var value: String = .empty
    @Published var commandsOutput = [String.empty]
    @Published var hasActiveTransaction = false
    @Published var showAlert = false
    var currentCommand: Command = .begin

    /// Property indicating if both text fields are not empty
    var fieldsHaveValues: Binding<Bool> {
        Binding(
            get: { self.keyFieldIsNotEmpty.wrappedValue && self.valueFieldIsNotEmpty.wrappedValue },
            set: { _ in }
        )
    }

    var keyFieldIsNotEmpty: Binding<Bool> {
        Binding(
            get: { self.key.isNotEmpty() },
            set: { _ in }
        )
    }

    var valueFieldIsNotEmpty: Binding<Bool> {
        Binding(
            get: { self.value.isNotEmpty() },
            set: { _ in }
        )
    }

    private var transactionsStack: TransactionsStackProtocol

    init(transactionsStack: TransactionsStackProtocol = TransactionsStack()) {
        self.transactionsStack = transactionsStack
    }

    func execute(command: Command) {
        switch command {
        case .set(let register):
            handleSetCommand(register)
        case .get(let key):
            handleGetCommand(key)
        case .delete(let key):
            handleDeleteCommand(key)
        case .count(let value):
            handleCountCommand(value)
        case .begin:
            transactionsStack.begin()
            hasActiveTransaction = transactionsStack.hasActiveTransaction()
        case .commit:
            handleCommitCommand()
            hasActiveTransaction = transactionsStack.hasActiveTransaction()
        case .rollback:
            handleRollbackCommand()
            hasActiveTransaction = transactionsStack.hasActiveTransaction()
        }
        resetTextFieldValues()
    }

    private func handleSetCommand(_ register: Register) {
        transactionsStack.set(register) { result in
            switch result {
            case .success(let insertedValue):
                self.commandsOutput.append("> SET \(self.key) \(insertedValue)")
                break
            case .failure(_):
                break
            }
        }
    }

    private func handleGetCommand(_ key: String) {
        transactionsStack.get(by: key) { result in
            switch result {
            case .success(let foundValue):
                self.commandsOutput.append("> GET \(self.key)")
                self.commandsOutput.append("\(foundValue)")
                break
            case .failure(let error):
                switch error {
                case .noKeyFound:
                    self.commandsOutput.append("key not set")
                case .retrievalError:
                    self.commandsOutput.append("Retrieval error")
                }
                break
            }
        }
    }

    private func handleDeleteCommand(_ key: String) {
        transactionsStack.delete(key: key) { result in
            switch result {
            case .success(let deletedValue):
                self.commandsOutput.append("Deleted value: \(deletedValue)")
                break
            case .failure(let error):
                switch error {
                case .noKeyFound:
                    self.commandsOutput.append("key not set")
                case .deletionError:
                    self.commandsOutput.append("Deletion error")
                }
                break
            }
        }
    }

    private func handleCountCommand(_ value: String) {
        transactionsStack.count(of: value) { result in
            switch result {
            case .success(let totalCount):
                self.commandsOutput.append("> COUNT \(value)")
                self.commandsOutput.append("\(totalCount)")
                break
            case .failure(_):
                self.commandsOutput.append("Error in operation")
                break
            }
        }
    }

    private func handleCommitCommand() {
        transactionsStack.commit { result in
            switch result {
            case .success(_):
                self.commandsOutput.append("Commit successful")
                break
            case .failure(let error):
                switch error {
                case .noActiveTransaction:
                    self.commandsOutput.append("no transaction")
                }
            }
        }
    }

    private func handleRollbackCommand() {
        transactionsStack.rollback  { result in
            switch result {
            case .success(_):
                self.commandsOutput.append("Rollback successful")
                break
            case .failure(let error):
                switch error {
                case .noActiveTransaction:
                    self.commandsOutput.append("no transaction")
                }
                break
            }
        }
    }

    private func resetTextFieldValues() {
        key = .empty
        value = .empty
    }
}
