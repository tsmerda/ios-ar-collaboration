//
//  ARViewContainer.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 28.01.2023.
//

import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ARViewContainer>) -> RealityViewController {
        let viewController = RealityViewController()
        
        if let usdzModel = viewModel.usdzModel {
            viewController.usdzModel = usdzModel
        }
        
        return viewController
    }

    func updateUIViewController(_ viewController: RealityViewController, context: UIViewControllerRepresentableContext<ARViewContainer>) {
        if let usdzModel = viewModel.usdzModel {
//            viewController.resetSession() // Reset configuration and remove models
            viewController.usdzModel = usdzModel
        }
    }
}
