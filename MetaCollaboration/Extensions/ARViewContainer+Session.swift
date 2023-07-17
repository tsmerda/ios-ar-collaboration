//
//  ARViewContainer+Session.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 13.05.2023.
//

import Foundation
import ARKit
import RealityKit

struct ObjectType: Component {
    enum ObjectKind {
        case detected
        case inserted
    }
    
    let kind: ObjectKind
}

extension ARViewContainer {
    // Communicate changes from UIView to SwiftUI by updating the properties of your coordinator
    // Confrom the coordinator to ARSessionDelegate
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func createBoundingBoxEntity(extent: SIMD3<Float>) -> ModelEntity {
            let boxMesh = MeshResource.generateBox(size: extent)
            let boxMaterial = SimpleMaterial(color: .red.withAlphaComponent(0.15), isMetallic: false)
            let boundingBoxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
            boundingBoxEntity.generateCollisionShapes(recursive: true)
            return boundingBoxEntity
        }
        
        // Kontrola a správa nově přidaných anchors
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
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
                    
                    // MARK: -- Detected 3D object
                    // Get Anchor of detected 3D object from scene and paste same Anchor to func placeSceneObject for handling USDZ models above 3D object
                    
                    print("Detected object anchor")
                    
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
                    self.parent.viewModel.arView.placeSceneObject(for: objectAnchor, self.parent.viewModel)
                } else {
                    // Kontrola, zda má anchor požadovaný název modelu
                    //                    if let anchorName = anchor.name, anchorName == "cake" {
                    //                        print("DIDADD \(anchor)")
                    //                    self.parent.viewModel.arView.placeSceneObject(for: anchor)
                    //                    }
                }
            }
        }
        
        //    TODO: -- FIX
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
            //            else {
            //                print("Deferred sending collaboration to later because there are no peers.")
            //            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
