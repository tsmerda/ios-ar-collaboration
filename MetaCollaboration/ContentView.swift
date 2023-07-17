//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    @State private var showingSheet = false
    
    var body: some View {
        ZStack {
            TabView {
                //                if UserDefaults.standard.string(forKey: "appMode") != "onlineMode" {
                DatasetListView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Menu", systemImage: "list.dash")
                    }
                //                }
                
                ZStack(alignment: .center) {
                    //                    if viewModel.arMode == activeARMode.recognitionMode {
                    //                        CollaborationView(showingSheet: $showingSheet)
                    //                            .environmentObject(viewModel)
                    //                            .zIndex(1)
                    //                            .id(viewModel.uniqueID)
                    //                            .sheet(isPresented: $showingSheet) {
                    //                                GuideView()
                    //                                    .environmentObject(viewModel)
                    //                            }
                    //                            .onAppear {
                    //                                viewModel.refreshCollaborationView()
                    //                            }
                    //                    } else {
                    ARViewContainer(showingSheet: $showingSheet)
                        .environmentObject(viewModel)
                        .zIndex(1)
                        .id(viewModel.uniqueID)
                        .sheet(isPresented: $showingSheet) {
                            GuideView()
                                .environmentObject(viewModel)
                        }
                        .onAppear {
                            viewModel.refreshCollaborationView()
                        }
                    //                    }
                    
                    //                    if viewModel.arMode == activeARMode.collaborationMode {
                    VStack {
                        HStack {
                            VStack {
                                if let peerNames = viewModel.multipeerSession?.peerDisplayNames, !(viewModel.multipeerSession?.peerDisplayNames.isEmpty)! {
                                    // array is not empty
                                    Text("Connected peers")
                                        .fontWeight(.bold)
                                    
                                    ForEach(peerNames, id: \.self) { displayName in
                                        Text(displayName)
                                    }
                                } else {
                                    // array is empty or nil
                                    Text("Currently no peers connected")
                                        .fontWeight(.bold)
                                }
                            }
                            .padding()
                            
                            Spacer()
                            
                            //                            Button(action: {
                            //                                viewModel.arMode = activeARMode.recognitionMode
                            //                            }) {
                            //                                RoundedRectangle(cornerRadius: 10)
                            //                                    .foregroundColor(Color.white)
                            //                                    .frame(width: 50, height: 50)
                            //                                    .overlay(
                            //                                        Image(systemName: "xmark")
                            //                                            .foregroundColor(.black)
                            //                                    )
                            //                            }
                            //                            .padding(.top, 15)
                            //                            .padding(.trailing, 15)
                        }
                        
                        Spacer()
                    }
                    .zIndex(2)
                    //                    }
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
        .onAppear {
            viewModel.getAllGuides()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
