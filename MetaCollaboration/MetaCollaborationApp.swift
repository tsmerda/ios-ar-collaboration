//
//  MetaCollaborationApp.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

@main
struct MetaCollaborationApp: App {
    @StateObject var viewModel = CollaborationViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.appMode == activeAppMode.none {
                ChooseModeView()
                    .environmentObject(viewModel)
            }
            else {
                ContentView()
                    .environmentObject(viewModel)
            }
        }
    }
}
