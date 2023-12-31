//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appMode") var appMode: ActiveAppMode = .none
    @StateObject var nav = NavigationStateManager()
    @StateObject var guideListViewModel = GuideListViewModel()
    
    var body: some View {
        NavigationStack(path: $nav.path) {
            if appMode == .none {
                ChooseModeView()
            } else {
                GuideListView(viewModel: guideListViewModel)
            }
        }
        .environmentObject(nav)
    }
}

#Preview {
    ContentView()
}
