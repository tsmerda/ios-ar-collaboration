//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct ContentView: View {
//    @AppStorage("appMode") var appMode: ActiveAppMode = .none
//    @AppStorage("collaborationMode") var collaborationMode: Bool = false
//    
//    init() {
//        collaborationMode = false
//    }
    
    var body: some View {
        ZStack {
            // TODO: -- Future implementation ChooseModeView()
//            if appMode == .none {
//                ChooseModeView()
//            } else {
//                GuideListView()
//            }
        }
//        .alert("Server Error", isPresented: $viewModel.hasError) {
//            Button("Retry") { viewModel.getAllGuides() }
//        } message: {
//            if case let .failed(error) = viewModel.networkState {
//                Text(error.localizedDescription)
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
