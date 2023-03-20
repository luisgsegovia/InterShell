//
//  Extensions.swift
//  InterShell
//
//  Created by Luis Segovia on 16/03/23.
//

import SwiftUI

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension String {
    static let empty = ""

    func isNotEmpty() -> Bool {
        return self != .empty
    }
}

extension String {
    static let courierNewFontName: String = "Courier New"
    static let courierNewBoldFontName: String = "Courier New Bold"
}

extension CGFloat {
    static let defaultFontSize: CGFloat = 16.0
    static let bigFontSize: CGFloat = 20.0
}
