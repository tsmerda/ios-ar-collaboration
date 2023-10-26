//
//  GuideListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct GuideListView: View {
    @StateObject private var viewModel: GuideListViewModel
    @State private var isShowingSettings: Bool = false
    @State private var path = NavigationPath()
    private let progressHudBinding: ProgressHudBinding
    
    init(viewModel: GuideListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                guideList
                Spacer()
            }
            .background(Color("backgroundColor")
                .ignoresSafeArea(.all, edges: .all))
            .navigationTitle("Guides")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    settingsButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshGuidesButton
                }
            }
            .navigationDestination(for: Guide.self) { guide in
                GuideDetailView(
                    viewModel: GuideDetailViewModel(
                        guide: guide,
                        downloadedGuides: viewModel.downloadedGuides,
                        onDownloadGuide: { viewModel.downloadedGuides.append($0) }
                    )
                )
            }
            // TODO: -- fix this to deinitialize CollaborationView
            //            .navigationDestination(isPresented: $showCollaborationView) {
            //                if let currentGuide = viewModel.currentGuide {
            //                    CollaborationView(
            //                        viewModel: CollaborationViewModel(
            //                            currentGuide: currentGuide,
            //                            referenceObjects: viewModel.referenceObjects
            //                        )
            //                    )
            //                    .onDisappear {
            //                        // Deinitialize CollaborationViewModel
            //                        debugPrint("CollaborationView disappear")
            //                        viewModel.currentGuide = nil
            //                    }
            //                }
            //            }
        }
        .onAppear {
            viewModel.getAllGuides()
        }
        .sheet(isPresented: $isShowingSettings) {
            settingsView
        }
    }
}

private extension GuideListView {
    var guideList: some View {
        List {
            if let guideList = viewModel.guideList, !guideList.isEmpty {
                ForEach(guideList) { guide in
                    NavigationLink(value: guide) {
                        GuideRowView(
                            guide: guide,
                            isDownloaded: viewModel.isGuideIdDownloaded(guide.id)
                        )
                    }
                    .foregroundColor(.accentColor)
                    .listRowBackground(Color("secondaryColor"))
                }
            } else {
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
    }
    var settingsButton: some View {
        Button(action: {
            isShowingSettings = true
        }) {
            Image(systemName: "slider.horizontal.3")
        }
    }
    var refreshGuidesButton: some View {
        Button(action: { viewModel.getAllGuides() }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(.accentColor)
        }
    }
    var loadingView: LoadingView {
        LoadingView()
    }
    var settingsView: SettingsView {
        let viewModel = SettingsViewModel(
            removeAllFromLocalStorage: viewModel.removeAllFromLocalStorage
        )
        return SettingsView(viewModel: viewModel)
    }
    var emptyView: EmptyView {
        EmptyView()
    }
}

#Preview {
    GuideListView(viewModel: GuideListViewModel())
}
