//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appMode") var appMode: ActiveAppMode = .none
    
    var body: some View {
        ZStack {
            if appMode == .none {
                ChooseModeView()
            } else {
                GuideListView(viewModel: GuideListViewModel())
            }
        }
    }
}

#Preview {
    ContentView()
}
