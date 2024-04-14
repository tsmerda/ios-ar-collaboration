//
//  ARViewContainer.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 28.01.2023.
//

import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var viewModel: CollaborationViewModel
    /// @Binding var showStepSheet: Bool
    
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        viewModel.initializeARViewContainer()
        viewModel.arView.session.delegate = context.coordinator
        /// viewModel.arView.gestureSetup(showStepSheet: $showStepSheet)
        viewModel.arView.gestureSetup()
        return viewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
