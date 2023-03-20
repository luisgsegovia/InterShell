//
//  CommandButton.swift
//  InterShell
//
//  Created by Luis Segovia on 16/03/23.
//

import SwiftUI

struct CommandButton: View {
    var title: String
    var action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }


    var body: some View {
        Button(title, action: action)
            .font(.custom(.courierNewFontName, size: .bigFontSize))
            .padding([.leading, .trailing], 20)
            .padding([.top, .bottom], 10)
            .background(Color(hex: 0xE8DED1))
            .clipShape(Capsule())
    }
}

struct CommandButton_Previews: PreviewProvider {
    static var previews: some View {
        CommandButton("SET", action: {})
    }
}
