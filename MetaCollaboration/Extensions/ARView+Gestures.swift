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
        
        guard let touchInView = sender?.location(in: self) else {
            return
        }
        
        if let hitEntity = self.entity(at: touchInView) {
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
        //        else if let result = self.raycast(
        //            from: touchInView,
        //            allowing: .existingPlaneGeometry,
        //            alignment: .horizontal
        //        ).first {
        //            self.addNewAnchor(transform: result.worldTransform)
        //        }
    }
    
    func placeSceneObject(for anchor: ARAnchor, _ viewModel: CollaborationViewModel) {
        guard let usdzModel = viewModel.usdzModel else {
            print("Error: No model URL provided")
            return
        }
        do {
            let modelAnchor = AnchorEntity(anchor: anchor)
            
            // Create and add entity to newAnchor
            let entity = try ModelEntity.loadModel(contentsOf: usdzModel, withName: usdzModel.lastPathComponent)
            entity.generateCollisionShapes(recursive: true)
            // Play model animation
            // for anim in entity.availableAnimations {
            //      entity.playAnimation(anim.repeat(duration: .infinity), transitionDuration: 1.25, startsPaused: false)
            // }
            // Insert next to detected object
            let modelTranslation = SIMD3<Float>(0.1, 0, 0)
            let modelTransform = Transform(translation: modelTranslation)
            entity.transform = modelTransform
            entity.transform.scale = simd_float3(0.01, 0.01, 0.01)
            modelAnchor.addChild(entity)
            
            // self.installGestures([.all], for: entity)
            modelAnchor.synchronization?.ownershipTransferMode = .autoAccept
            modelAnchor.anchoring = AnchoringComponent(anchor)
            
            
            // Create and add label to newAnchor using SpriteKit
            let textAnchor = AnchorEntity(anchor: anchor)
            // Insert next to detected object
            let textTranslation = SIMD3<Float>(0, 0.2, 0)
            let textTransform = Transform(translation: textTranslation)
            let textModel = textGen(textString: "Detected object")
            textModel.transform = textTransform
            textAnchor.addChild(textModel)
            
            self.scene.addAnchor(textAnchor)
            self.scene.addAnchor(modelAnchor)
            self.session.add(anchor: anchor)
        } catch {
            print("Error: Failed to load entity from URL \(usdzModel): \(error)")
        }
    }
    
    func textGen(textString: String) -> ModelEntity {
        let fontVar = UIFont.systemFont(ofSize: 0.01)
        let containerFrameVar = CGRect(x: -0.05, y: -0.08, width: 0.1, height: 0.1)
        let alignmentVar: CTTextAlignment = .center
        let lineBreakModeVar: CTLineBreakMode = .byWordWrapping
        
        let textMeshResource: MeshResource = .generateText(textString,
                                                           extrusionDepth: 0,
                                                           font: fontVar,
                                                           containerFrame: containerFrameVar,
                                                           alignment: alignmentVar,
                                                           lineBreakMode: lineBreakModeVar)
        
        let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMeshResource, materials: [textMaterial])
        
        let blackMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let backgroundPlane = ModelEntity(mesh: .generatePlane(width: 0.1, height: 0.05), materials: [blackMaterial])
        backgroundPlane.transform.translation = [0, 0, -0.0005]
        
        textEntity.addChild(backgroundPlane)
        
        return textEntity
    }
}

//            // Create and add model to newAnchor
//            let cubeModel = ModelEntity(
//                mesh: .generateBox(size: 0.05),
//                materials: [SimpleMaterial(color: .red, isMetallic: false)]
//            )
//            cubeModel.generateCollisionShapes(recursive: false)
//            //            self.installGestures([.all], for: cubeModel)
//            // Insert next to detected object
//            let translation = SIMD3<Float>(0.1, 0, 0)
//            let transform = Transform(translation: translation)
//            cubeModel.transform = transform
//            modelAnchor.addChild(cubeModel)
//
//            modelAnchor.synchronization?.ownershipTransferMode = .autoAccept
