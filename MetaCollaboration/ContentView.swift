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
                ZStack {
                    CollaborationView()
                        .environmentObject(viewModel)
                        .zIndex(1)
//                    Rectangle()
//                        .fill(Color.white)
//                        .frame(width: UIScreen.main.bounds.width, height: 30)
//                        .zIndex(2)
                }
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
