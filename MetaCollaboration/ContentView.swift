//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    @State private var showingSheet = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
                    .scaleEffect(1.5)
                    .zIndex(2)
            }
            
            TabView {
                if UserDefaults.standard.string(forKey: "appMode") != "onlineMode" {
                    DatasetListView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("Menu", systemImage: "list.dash")
                        }
                }
                
                ZStack(alignment: .center) {
                    if viewModel.arMode == activeARMode.recognitionMode {
                        CollaborationView()
                            .environmentObject(viewModel)
                            .zIndex(1)
                            .sheet(isPresented: $showingSheet) {
                                GuideView(guide: $viewModel.currentGuide)
                                    .environmentObject(viewModel)
                            }
                    } else {
                        ARViewContainer()
                            .environmentObject(viewModel)
                            .zIndex(1)
                            .sheet(isPresented: $showingSheet) {
                                GuideView(guide: $viewModel.currentGuide)
                                    .environmentObject(viewModel)
                            }
                    }
                    
                    if viewModel.arMode == activeARMode.recognitionMode {
                        VStack {
                            Button(action: {
                                self.showingSheet = true
                            }) {
                                HStack {
                                    Text(viewModel.ARResults)
                                        .font(.title3)
                                        .multilineTextAlignment(.leading)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer ()
                                }
                                .padding(.leading, 30)
                            }
                            .frame(width: UIScreen.main.bounds.width - 15, height: 70)
                            .background(.white)
                            .padding(.top, 30)
                            
                            Spacer()
                        }
                        .zIndex(2)
                    } else {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    viewModel.arMode = activeARMode.recognitionMode
                                }) {
                                    RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color.white)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .foregroundColor(.black)
                                            )
                                }
                                .padding(.top, 15)
                                .padding(.trailing, 15)
                            }
                            
                            Spacer()
                        }
                        .zIndex(2)
                    }
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
        .onAppear() {
            viewModel.getGuideById(id: "640b700f16cde6145a3bfc19")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
