//
//  CommandButtonsView.swift
//  InterShell
//
//  Created by Luis Segovia on 16/03/23.
//

import SwiftUI

enum CommandButtonTitle: String {
    case set
    case get
    case delete
    case begin
    case commit
    case rollback
    case count

    var value: String {
        return self.rawValue.uppercased()
    }
}

struct CommandButtonsView: View {
    @EnvironmentObject var viewModel: ViewModel

    private var key: String {
        return viewModel.key
    }

    private var value: String {
        return viewModel.value
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text("Commands")
                    .font(.custom(.courierNewBoldFontName, size: .defaultFontSize))
            }
            VStack {
                HStack {
                    CommandButton(
                        CommandButtonTitle.set.value,
                        action: {
                            self.execute(.set(
                                (key, value)
                            ))

                        })
                    .disabled(!viewModel.fieldsHaveValues.wrappedValue)

                    CommandButton(
                        CommandButtonTitle.get.value,
                        action: {
                            self.execute(.get(key: key))
                        })
                    .disabled(!viewModel.keyFieldIsNotEmpty.wrappedValue)

                    CommandButton(
                        CommandButtonTitle.delete.value,
                        action: {
                            viewModel.showAlert = true
                            viewModel.currentCommand = .delete(key: key)
                        })
                    .disabled(!viewModel.keyFieldIsNotEmpty.wrappedValue)
                }
                .padding(.top, 10)

                HStack {
                    CommandButton(
                        CommandButtonTitle.begin.value,
                        action: {
                            self.execute(.begin)
                        })

                    CommandButton(
                        CommandButtonTitle.commit.value,
                        action: {
                            viewModel.showAlert = true
                            viewModel.currentCommand = .commit
                        })
                    .disabled(!viewModel.hasActiveTransaction)

                    CommandButton(
                        CommandButtonTitle.rollback.value,
                        action: {
                            viewModel.showAlert = true
                            viewModel.currentCommand = .rollback
                        })
                    .disabled(!viewModel.hasActiveTransaction)
                }

                HStack {
                    CommandButton(
                        CommandButtonTitle.count.value, action: {
                            self.execute(.count(value: value))
                        })
                    .disabled(!viewModel.valueFieldIsNotEmpty.wrappedValue)
                }
                .padding(.bottom, 10)
            }
            .background(Color(hex: 0xfaf7f7))
            .cornerRadius(16)
            .alert("Caution", isPresented: $viewModel.showAlert) {
                Button("Continue", role: .destructive) {
                    self.execute(viewModel.currentCommand)
                }
            } message: {
                Text("This action cannot be undone")
            }
        }
    }

    private func execute(_ command: Command) {
        viewModel.execute(command: command)
    }
}



struct CommandButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        CommandButtonsView()
            .environmentObject(ViewModel())
    }
}
