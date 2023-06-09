//
//  ARViewContainer+Session.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 13.05.2023.
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
        
        // Kontrola a správa nově přidaných anchors
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let participantAnchor = anchor as? ARParticipantAnchor{
                    print("Established joint experience with a peer.")
                    
                    let anchorEntity = AnchorEntity(anchor: participantAnchor)
                    let mesh = MeshResource.generateSphere(radius: 0.03)
                    let color = UIColor.red
                    let material = SimpleMaterial(color: color, isMetallic: false)
                    let coloredSphere = ModelEntity(mesh:mesh, materials:[material])
                    
                    anchorEntity.addChild(coloredSphere)
                    
                    self.parent.viewModel.arView.scene.addAnchor(anchorEntity)
                } else if let objectAnchor = anchor as? ARObjectAnchor {
                    print("Detected object anchor")
                    
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
