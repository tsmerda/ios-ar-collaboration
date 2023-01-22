//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CollaborationViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
                    .scaleEffect(1.5)
                    .zIndex(2)
            }
            TabView {
                DatasetListView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Menu", systemImage: "list.dash")
                    }
                CollaborationView(mlModel: viewModel.textData)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Collaboration", systemImage: "viewfinder")
                    }
                InfoView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
