//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appMode") var appMode: ActiveAppMode = .none
    @AppStorage("collaborationMode") var collaborationMode: Bool = false
    
    @StateObject var viewModel = CollaborationViewModel()
    
    init() {
        collaborationMode = false
    }
    
    var body: some View {
        ZStack {
            if appMode == .none {
                ChooseModeView()
            } else if !collaborationMode {
                GuideListView()
                    .environmentObject(viewModel)
            } else {
                CollaborationView()
                    .environmentObject(viewModel)
            }
        }
    }
}

@available(iOS 16.4, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
