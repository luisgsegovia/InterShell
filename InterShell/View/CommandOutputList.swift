//
//  CommandOutputList.swift
//  InterShell
//
//  Created by Luis Segovia on 16/03/23.
//

import SwiftUI

struct CommandOutputList: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        ScrollViewReader { scrollView in
            VStack {
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.commandsOutput, id: \.self) { output in
                            VStack(alignment: .leading) {
                                Text(output)
                                    .font(.custom(.courierNewFontName, size: .bigFontSize))
                                    .foregroundColor(.white)
                                Divider()
                            }
                        }
                    }
                }.onChange(of: viewModel.commandsOutput.count) { _ in
                    withAnimation {
                        scrollView.scrollTo(viewModel.commandsOutput.count - 1)
                    }
                }
            }
            .background(Color.black)
            .cornerRadius(20)
            .padding(10)
        }
    }
}

struct CommandOutputList_Previews: PreviewProvider {
    static var previews: some View {
        CommandOutputList()
            .environmentObject(ViewModel())
    }
}
