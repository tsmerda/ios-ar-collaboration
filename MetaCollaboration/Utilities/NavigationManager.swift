//
//  NavigationManager.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 28.10.2023.
//

import SwiftUI

class NavigationStateManager: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func goBack() {
        path.removeLast()
    }
    
    func goToGuideDetail(_ guide: Guide) {
        path.append(guide)
    }
    
    func goToCollaborationView(_ guide: ExtendedGuideResponse) {
        path.append(guide)
    }
    
    func errorGoToView(_ view: String) {
        debugPrint("Error go to view: \(view)")
    }
}
