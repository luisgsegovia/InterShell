//
//  InputTextField.swift
//  InterShell
//
//  Created by Luis Segovia on 16/03/23.
//

import SwiftUI

struct InputTextField: View {
    var title: String
    var placeholder: String
    var text: Binding<String>

    init(title: String, placeholder: String, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom(.courierNewBoldFontName, size: .defaultFontSize))
            TextField(placeholder, text: text)
                .font(.custom(.courierNewFontName, size: .defaultFontSize))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        }
}

struct InputTextField_Previews: PreviewProvider {
    @State private var demoText = "Enter text here"

    static var previews: some View {
        InputTextField(title: "Value", placeholder: "Value", text: .constant(""))
    }
}
