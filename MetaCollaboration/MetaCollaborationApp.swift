//
//  MetaCollaborationApp.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

@main
struct MetaCollaborationApp: App {
    var body: some Scene {
        WindowGroup {
            GuideListView(viewModel: GuideListViewModel())
        }
    }
}
