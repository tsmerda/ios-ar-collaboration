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
                
                ZStack(alignment: .center) {
//                    CollaborationView()
//                        .environmentObject(viewModel)
//
                    ARViewContainer()
                        .zIndex(1)
                    
                    VStack {
                        Text(viewModel.ARResults)
                            .frame(width: UIScreen.main.bounds.width - 15, height: 80)
                            .background(.white)
                            .foregroundColor(.black)
                            .padding(.top, 30)
                        
                        Spacer()
                    }
                    .zIndex(2)
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
