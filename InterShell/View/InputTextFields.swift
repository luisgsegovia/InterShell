//
//  InputTextFields.swift
//  InterShell
//
//  Created by Luis Segovia on 16/03/23.
//

import Foundation
import SwiftUI

struct InputTextFields: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        HStack {
            InputTextField(title: "Key", placeholder: "Insert Key", text: $viewModel.key)
                .accessibilityIdentifier("keyTextField")
            InputTextField(title: "Value", placeholder: "Insert Value", text: $viewModel.value)
                .accessibilityIdentifier("valueTextField")
        }
        .padding(20)
    }
}

struct InputTextFields_Previews: PreviewProvider {
    static var previews: some View {
        InputTextFields()
            .environmentObject(ViewModel())
    }
}
