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
    
    private struct AssociatedKeys {
        static var collaborationViewModel = "collaborationViewModel"
    }
    
    var collaborationViewModel: CollaborationViewModel {
        get {
            guard let viewModel = objc_getAssociatedObject(self, &AssociatedKeys.collaborationViewModel) as? CollaborationViewModel else {
                let viewModel = CollaborationViewModel()
                objc_setAssociatedObject(self, &AssociatedKeys.collaborationViewModel, viewModel, .OBJC_ASSOCIATION_RETAIN)
                return viewModel
            }
            return viewModel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.collaborationViewModel, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func gestureSetup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
    }
    
    /// This function does sends a message "hello!" to all peers.
    /// If you tap on an existing entity, it will run a scale up and down animation
    /// If you tap on the floor without hitting any entities it will create a new Anchor
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let displayName = self.collaborationViewModel.multipeerSession?.printMyPeerID.displayName
        if let myData = "hello! from \(String(describing: displayName) ?? "Nobody")"
            .data(using: .unicode) {
            self.collaborationViewModel.multipeerSession?.sendToAllPeers(myData, reliably: true)
        }
        
        //    TODO: Add another interaction such as moving / rotation / scaling
        guard let touchInView = sender?.location(in: self) else {
            return
        }
        
        if let hitEntity = self.entity(at: touchInView) {
            if hitEntity.isOwner {
                //              let origTransform = Transform(scale: simd_float3(0.01, 0.01, 0.01), rotation: .init(), translation: .zero)
                //              let largerTransform = Transform(scale: .init(repeating: 0.02), rotation: .init(), translation: .zero)
                let origTransform = Transform(scale: .one, rotation: .init(), translation: .zero)
                let largerTransform = Transform(scale: .init(repeating: 1.5), rotation: .init(), translation: .zero)
                hitEntity.move(to: largerTransform, relativeTo: hitEntity.parent, duration: 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    hitEntity.move(to: origTransform, relativeTo: hitEntity.parent, duration: 0.2)
                }
            } else {
                hitEntity.requestOwnership { result in
                    if result == .granted {
                        let origTransform = Transform(scale: .one, rotation: .init(), translation: .zero)
                        let largerTransform = Transform(scale: .init(repeating: 1.5), rotation: .init(), translation: .zero)
                        hitEntity.move(to: largerTransform, relativeTo: hitEntity.parent, duration: 0.2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            hitEntity.move(to: origTransform, relativeTo: hitEntity.parent, duration: 0.2)
                        }
                    }
                }
            }
        } else if let result = self.raycast(
            from: touchInView,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal
        ).first {
            self.addNewAnchor(transform: result.worldTransform)
        }
    }
    
    //     TODO: -- Fix this function ???
    //    / Add a new anchor to the session
    //    / - Parameter transform: position in world space where the new anchor should be
    func addNewAnchor(transform: simd_float4x4) {
        //        guard let usdzModel = self.collaborationViewModel.usdzModel else {
        //            print("Error: No model URL provided")
        //            return
        //        }
        
        do {
            let arAnchor = ARAnchor(name: "Cube Anchor", transform: transform)
            let newAnchor = AnchorEntity(anchor: arAnchor)
            
            let cubeModel = ModelEntity(
                mesh: .generateBox(size: 0.1),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            cubeModel.generateCollisionShapes(recursive: false)
            self.installGestures([.all], for: cubeModel)
            
            newAnchor.addChild(cubeModel)
            
            newAnchor.synchronization?.ownershipTransferMode = .autoAccept
            
            newAnchor.anchoring = AnchoringComponent(arAnchor)
            self.scene.addAnchor(newAnchor)
            self.session.add(anchor: arAnchor)
            
            
            //            let entity = try ModelEntity.loadModel(contentsOf: usdzModel, withName: usdzModel.lastPathComponent)
            //            entity.generateCollisionShapes(recursive: true)
            //            entity.transform.scale = simd_float3(0.01, 0.01, 0.01)
            //
            //            for anim in entity.availableAnimations {
            //                entity.playAnimation(anim.repeat(duration: .infinity), transitionDuration: 1.25, startsPaused: false)
            //            }
            //
            //            let arAnchor = ARAnchor(name: "Entity Anchor", transform: transform)
            //            let anchorEntity = AnchorEntity(anchor: arAnchor)
            //            anchorEntity.addChild(entity)
            //
            //            self.installGestures([.all], for: entity)
            //            anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
            //            anchorEntity.anchoring = AnchoringComponent(arAnchor)
            //
            //            self.scene.addAnchor(anchorEntity)
            //            self.session.add(anchor: arAnchor)
        } catch {
            //            print("Error: Failed to load entity from URL \(usdzModel): \(error)")
        }
    }
    
    func placeSceneObject(for anchor: ARAnchor) {
        do {
            let newAnchor = AnchorEntity(anchor: anchor)
            
            let cubeModel = ModelEntity(
                mesh: .generateBox(size: 0.1),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            cubeModel.generateCollisionShapes(recursive: false)
            self.installGestures([.all], for: cubeModel)
            
            newAnchor.addChild(cubeModel)
            
            newAnchor.synchronization?.ownershipTransferMode = .autoAccept
            
            self.scene.addAnchor(newAnchor)
            //            self.session.add(anchor: arAnchor)
        } catch {
            //            print("Error: Failed to load entity from URL \(usdzModel): \(error)")
        }
    }
}
