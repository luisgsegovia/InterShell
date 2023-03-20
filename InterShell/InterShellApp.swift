//
//  InterShellApp.swift
//  InterShell
//
//  Created by Luis Segovia on 09/03/23.
//

import SwiftUI

@main
struct InterShellApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: ViewModel())
        }
    }
}
