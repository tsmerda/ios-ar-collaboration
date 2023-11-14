//
//  GuideListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct GuideListView: View {
    @EnvironmentObject var nav: NavigationStateManager
    @StateObject private var viewModel: GuideListViewModel
    @State private var isShowingSettings: Bool = false
    private let progressHudBinding: ProgressHudBinding
    
    init(viewModel: GuideListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea(.all, edges: .all)
            guideList
        }
        .navigationTitle("Guides")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                settingsButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                refreshGuidesButton
            }
        }
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Guide.self) { guide in
            GuideDetailView(
                viewModel: GuideDetailViewModel(
                    guide: guide
                )
            )
        }
        .onAppear {
            // Check downloaded guide saved in local storage
            viewModel.downloadedGuides = PersistenceManager.shared.loadGuidesFromJSON()
        }
        .sheet(isPresented: $isShowingSettings) {
            settingsView
        }
    }
}

private extension GuideListView {
    var guideList: some View {
        VStack {
            if let guideList = viewModel.guideList,
               !guideList.isEmpty {
                ForEach(guideList, id: \.id) { guide in
                    Button(action: {
                        nav.goToGuideDetail(guide)
                    }) {
                        GuideRowView(
                            guide: guide,
                            isDownloaded: viewModel.isGuideIdDownloaded(guide.id),
                            isCompleted: viewModel.isGuideCompleted(guide.id)
                        )
                    }
                    .listRowBackground(Color("secondaryColor"))
                }
                Spacer()
            } else {
                HStack {
                    Spacer()
                    Text("There are currently no datasets available")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.title3)
                    Spacer()
                }
                .frame(maxWidth: 260)
            }
        }
        .padding()
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
        return SettingsView(removeAllFromLocalStorage: viewModel.removeAllFromLocalStorage)
    }
    var emptyView: EmptyView {
        EmptyView()
    }
}

#Preview {
    GuideListView(viewModel: GuideListViewModel())
}
