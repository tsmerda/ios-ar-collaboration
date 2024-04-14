//
//  ARViewContainer+Ext.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 14.04.2024.
//

import Foundation
import ARKit
import RealityKit

extension ARViewContainer {
    // Communicate changes from UIView to SwiftUI by updating the properties of your coordinator
    // Confrom the coordinator to ARSessionDelegate
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func createBoundingBoxEntity(extent: SIMD3<Float>) -> ModelEntity {
            let boundingBoxEntity = ModelEntity()
            
            // Line properties
            let lineThickness: Float = 0.001 // Thickness of the lines
            
            // Function to create a single line
            func createLine(start: SIMD3<Float>, end: SIMD3<Float>) -> ModelEntity {
                let lineLength = simd_distance(start, end)
                let lineCenter = (start + end) / 2
                let lineDirection = simd_normalize(end - start)
                let orientation = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: lineDirection)
                
                let hexColor = UIColor(hex: "#F2E900")
                
                let lineMesh = MeshResource.generateBox(size: SIMD3(lineThickness, lineThickness, lineLength))
                let lineMaterial = UnlitMaterial(color: hexColor)
                let line = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
                line.position = lineCenter
                line.orientation = orientation
                return line
            }
            
            // Create lines for each edge of the bounding box
            let vertices = [
                SIMD3<Float>(-extent.x / 2, -extent.y / 2, -extent.z / 2),
                SIMD3<Float>( extent.x / 2, -extent.y / 2, -extent.z / 2),
                SIMD3<Float>(-extent.x / 2,  extent.y / 2, -extent.z / 2),
                SIMD3<Float>( extent.x / 2,  extent.y / 2, -extent.z / 2),
                SIMD3<Float>(-extent.x / 2, -extent.y / 2,  extent.z / 2),
                SIMD3<Float>( extent.x / 2, -extent.y / 2,  extent.z / 2),
                SIMD3<Float>(-extent.x / 2,  extent.y / 2,  extent.z / 2),
                SIMD3<Float>( extent.x / 2,  extent.y / 2,  extent.z / 2)
            ]
            
            let edges = [
                (0, 1), (1, 3), (3, 2), (2, 0), // Bottom edges
                (4, 5), (5, 7), (7, 6), (6, 4), // Top edges
                (0, 4), (1, 5), (2, 6), (3, 7)  // Vertical edges
            ]
            
            for edge in edges {
                let line = createLine(start: vertices[edge.0], end: vertices[edge.1])
                boundingBoxEntity.addChild(line)
            }
            
            return boundingBoxEntity
        }
        
        // Check and manage newly added anchors
        #if !targetEnvironment(simulator)
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                print("participantAnchor NOW discovered")
                if let participantAnchor = anchor as? ARParticipantAnchor{
                    print("Established joint experience with a peer.")
                    
                    let anchorEntity = AnchorEntity(anchor: participantAnchor)
                    let mesh = MeshResource.generateSphere(radius: 0.02)
                    let color = UIColor.red
                    let material = SimpleMaterial(color: color, isMetallic: false)
                    let coloredSphere = ModelEntity(mesh:mesh, materials:[material])
                    
                    anchorEntity.addChild(coloredSphere)
                    
                    self.parent.viewModel.arView.scene.addAnchor(anchorEntity)
                } else if let objectAnchor = anchor as? ARObjectAnchor {
                    // Detected 3D object
                    // Get Anchor of detected 3D object from scene and paste same Anchor to func placeSceneObject for handling USDZ models above 3D object
                    print("Detected object anchor")
                    
                    // Check if a model for this anchor already exists in the scene
                    if isModelAlreadyAdded(for: objectAnchor) {
                        print("Model for this anchor already exists, skipping...")
                        continue // Skip adding a new model for this anchor
                    }
                    
                    // Bounding box for detected object
                    let boundingBoxEntity = createBoundingBoxEntity(extent: objectAnchor.referenceObject.extent)
                    boundingBoxEntity.components[ObjectType.self] = ObjectType(kind: .detected)
                    
                    // Adjust the position of the bounding box to match the position of the detected object
                    let positionOffset = objectAnchor.referenceObject.center
                    boundingBoxEntity.position = positionOffset
                    
                    let anchorEntity = AnchorEntity(anchor: objectAnchor)
                    anchorEntity.addChild(boundingBoxEntity)
                    
                    // Create coordinate axes
                    let axisLength: Float = 0.025
                    let xAxisEntity = ModelEntity(mesh: MeshResource.generateBox(size: SIMD3(axisLength, 0.002, 0.002)))
                    let yAxisEntity = ModelEntity(mesh: MeshResource.generateBox(size: SIMD3(0.002, axisLength, 0.002)))
                    let zAxisEntity = ModelEntity(mesh: MeshResource.generateBox(size: SIMD3(0.002, 0.002, axisLength)))
                    
                    xAxisEntity.position = SIMD3(axisLength / 2, 0, 0)
                    yAxisEntity.position = SIMD3(0, axisLength / 2, 0)
                    zAxisEntity.position = SIMD3(0, 0, axisLength / 2)
                    
                    xAxisEntity.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
                    yAxisEntity.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                    zAxisEntity.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
                    
                    anchorEntity.addChild(xAxisEntity)
                    anchorEntity.addChild(yAxisEntity)
                    anchorEntity.addChild(zAxisEntity)
                    
                    self.parent.viewModel.arView.scene.addAnchor(anchorEntity)
                    
                    // Call function for handling USDZ models
                    if let usdzModelURL = self.parent.viewModel.getUSDZModelForCurrentStep() {
                        self.parent.viewModel.arView.placeSceneObject(for: objectAnchor, with: usdzModelURL)
                    }
                } else {
                    print("some anchor NOW discovered")
                    /// Check if the anchor has the required model name
                    /// if let anchorName = anchor.name, anchorName == "cake" {
                    ///    print("DIDADD \(anchor)")
                    ///    self.parent.viewModel.arView.placeSceneObject(for: anchor)
                    /// }
                }
            }
        }
        #endif
        
        private func isModelAlreadyAdded(for objectAnchor: ARObjectAnchor) -> Bool {
            // Iterate over all entities in the scene and check if any of them are associated with the given anchor
            for entity in self.parent.viewModel.arView.scene.anchors {
                if let anchor = entity.anchor as? ARObjectAnchor, anchor == objectAnchor,
                   entity.children.contains(where: { $0.components.has(ModelComponent.self) }) {
                    return true // Found a model entity associated with this anchor
                }
            }
            return false // No model entity found for this anchor
        }
        
        //    TODO: - Fix
        //        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        //            for anchor in anchors {
        //                guard let anchorEntity = self.parent.viewModel.arView.scene.anchors.first(where: { $0.anchor == anchor }) else { continue }
        //                // Update the position of the child entity to match the anchor position
        //                let newPosition = anchor.transform.translation
        //                anchorEntity.children[0].position = newPosition
        //            }
        //        }
        
        func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
            guard let multipeerSession = self.parent.viewModel.multipeerSession else { return }
            if !multipeerSession.connectedPeers.isEmpty {
                guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                else { fatalError("Unexpectedly failed to encode collaboration data.") }
                // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
                let dataIsCritical = data.priority == .critical
                multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
            }
            /// else {
            ///    debugPrint("Deferred sending collaboration to later because there are no peers.")
            /// }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
