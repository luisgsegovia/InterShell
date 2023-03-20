//
//  MainView.swift
//  InterShell
//
//  Created by Luis Segovia on 09/03/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        VStack {
            CommandOutputList()
                .frame(height: 300)
            InputTextFields()
            CommandButtonsView()
            Spacer(minLength: 200)
        }.environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: ViewModel())
    }
}
