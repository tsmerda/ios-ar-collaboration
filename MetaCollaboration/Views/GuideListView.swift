//
//  GuideListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI
import CoreML
import Vision

struct GuideListView: View {
    
    @AppStorage("collaborationMode") var collaborationMode: Bool = false
    
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    @State private var isShowingSettings: Bool = false
    
    var body: some View {
        ZStack {
            switch viewModel.networkState {
            case .success:
                NavigationView {
                    VStack {
                        List {
                            if let guideList = viewModel.guideList, !guideList.isEmpty {
                                // array is not empty
                                ForEach(guideList) { guide in
                                    NavigationLink(destination: GuideDetailView(guide: guide, downloadedGuide: viewModel.downloadedGuideById(guide.id!), onGetGuideAction: {
                                        Task {
                                            await viewModel.getGuideById(id: guide.id!)
                                        }
                                        
                                    }, onSetCurrentGuideAction: {
                                        Task {
                                            await viewModel.getStepById(guide.id!, 1)
                                            if viewModel.currentStep != nil {
                                                viewModel.setCurrentGuide(guide.id!)
                                                collaborationMode = true
                                            }
                                        }
                                    })) {
                                        GuideRowView(guide: guide, isDownloaded: viewModel.isGuideIdDownloaded(guide.id!))
                                    }
                                    .foregroundColor(.accentColor)
                                    .listRowBackground(Color("secondaryColor"))
                                }
                            } else {
                                // array is empty or nil
                                HStack {
                                    Spacer()
                                    Text("No dataset available")
                                        .foregroundColor(.black)
                                        .font(.callout)
                                    Spacer()
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        
                        Spacer()
                    }
                    .background(Color("backgroundColor")
                        .ignoresSafeArea(.all, edges: .all))
                    .navigationTitle("Guides")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                isShowingSettings = true
                            }) {
                                Image(systemName: "slider.horizontal.3")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // Refresh guides
                                Task {
                                    await viewModel.getAllGuides()
                                }
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            case .loading:
                LoadingView()
            default:
                EmptyView()
            }
            
            
        }
        .task {
            await viewModel.getAllGuides()
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .environmentObject(viewModel)
        }
    }
}

struct GuideListView_Previews: PreviewProvider {
    static var previews: some View {
        GuideListView()
            .environmentObject(CollaborationViewModel())
    }
}
