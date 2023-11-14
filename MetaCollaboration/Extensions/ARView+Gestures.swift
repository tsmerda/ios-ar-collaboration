//
//  ARView+Gestures.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 13.05.2023.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

extension ARView {
    // Extend ARView to implement tapGesture handler
    // Hybrid workaround between UIKit and SwiftUI
    
//    func gestureSetup(showStepSheet: Binding<Bool>) {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        self.addGestureRecognizer(tap)
//        self.collaborationViewModel.showStepSheet = showStepSheet
//    }
        func gestureSetup() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            self.addGestureRecognizer(tap)
        }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // TODO: - This function does sends a message "hello!" to all peers.
        //        let displayName = self.collaborationViewModel.multipeerSession?.printMyPeerID.displayName
        //        if let myData = "hello! from \(String(describing: displayName))"
        //            .data(using: .unicode) {
        //            self.collaborationViewModel.multipeerSession?.sendToAllPeers(myData, reliably: true)
        //        }
        
        guard let touchInView = sender?.location(in: self) else {
            return
        }
        
        if let hitEntity = self.entity(at: touchInView) {
            if let objectType = hitEntity.components[ObjectType.self] as? ObjectType {
                switch objectType.kind {
                case .detected:
                    debugPrint("Tapped on a detected object")
//                    self.collaborationViewModel.showStepSheet?.wrappedValue = true
                    
                case .inserted:
                    /// If you tap on an existing entity, it will run a scale up and down animation
                    debugPrint("Tapped on an inserted object")
                    
                    if hitEntity.isOwner {
                        //              let origTransform = Transform(scale: simd_float3(0.01, 0.01, 0.01), rotation: .init(), translation: .zero)
                        //              let largerTransform = Transform(scale: .init(repeating: 0.02), rotation: .init(), translation: .zero)
                        //              let origTransform = Transform(scale: .one, rotation: .init(), translation: .zero)
                        let origTransform = hitEntity.transform
                        let largerTransform = Transform(scale: origTransform.scale * 1.3, rotation: origTransform.rotation, translation: origTransform.translation)
                        
                        hitEntity.move(to: largerTransform, relativeTo: hitEntity.parent, duration: 0.2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            hitEntity.move(to: origTransform, relativeTo: hitEntity.parent, duration: 0.2)
                        }
                    } else {
                        hitEntity.requestOwnership { result in
                            if result == .granted {
                                let origTransform = hitEntity.transform // Store the original transform
                                let largerTransform = Transform(scale: origTransform.scale * 1.3, rotation: origTransform.rotation, translation: origTransform.translation)
                                
                                hitEntity.move(to: largerTransform, relativeTo: hitEntity.parent, duration: 0.2)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    hitEntity.move(to: origTransform, relativeTo: hitEntity.parent, duration: 0.2)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //        else if let result = self.raycast(
        //            from: touchInView,
        //            allowing: .existingPlaneGeometry,
        //            alignment: .horizontal
        //        ).first {
        //            self.addNewAnchor(transform: result.worldTransform)
        //        }
    }
    
    #if !targetEnvironment(simulator)
    func placeSceneObject(for anchor: ARObjectAnchor, with modelURL: URL) {
        do {
            let modelAnchor = AnchorEntity(anchor: anchor)
            
            // Create and add entity to newAnchor
             let entity = try ModelEntity.loadModel(contentsOf: modelURL, withName: modelURL.lastPathComponent)
//            guard let entity = try? Entity.load(named: "CamelAnotation") else {
//                print("Error: No model URL provided")
//                return
//            }
            
            entity.generateCollisionShapes(recursive: true)
            entity.components[ObjectType.self] = ObjectType(kind: .inserted)
            
            /// Run USDZ animation
            /// for anim in entity.availableAnimations {
            ///      entity.playAnimation(anim.repeat(duration: .infinity), transitionDuration: 1.25, startsPaused: false)
            /// }
            
            /// Bounding box of detected object
            /// let boundingBoxSize = anchor.referenceObject.extent
            /// let centerTranslation = SIMD3<Float>(boundingBoxCenter.x, boundingBoxCenter.y, boundingBoxCenter.z)
            
            modelAnchor.addChild(entity)
            
            /// self.installGestures([.all], for: entity)
            
            modelAnchor.synchronization?.ownershipTransferMode = .autoAccept
            modelAnchor.anchoring = AnchoringComponent(anchor)
            
            self.scene.addAnchor(modelAnchor)
            self.session.add(anchor: anchor)
        } catch {
            print("Error: Failed to load entity: \(error)")
        }
    }
    #endif
}
