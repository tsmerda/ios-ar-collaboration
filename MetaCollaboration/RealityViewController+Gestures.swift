//
//  RealityViewController+Gestures.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 28.01.2023.
//

import ARKit
import RealityKit
import UIKit

extension RealityViewController: UIGestureRecognizerDelegate {
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arView.addGestureRecognizer(tap)
    }
    
    /// This function does sends a message "hello!" to all peers.
    /// If you tap on an existing entity, it will run a scale up and down animation
    /// If you tap on the floor without hitting any entities it will create a new Anchor
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let displayName = self.multipeerHelp.myPeerID.displayName
        if let myData = "hello! from \(displayName)"
            .data(using: .unicode) {
            multipeerHelp.sendToAllPeers(myData, reliably: true)
        }
        
        
        //    TODO: Add another interaction such as moving / rotation / scaling
        guard let touchInView = sender?.location(in: self.arView) else {
            return
        }
        if let hitEntity = self.arView.entity(at: touchInView) {
            // animate the Entity
            hitEntity.runWithOwnership { (result) in
                switch result {
                case .success:
                    let origTransform = Transform(scale: .one, rotation: .init(), translation: .zero)
                    let largerTransform = Transform(scale: .init(repeating: 1.5), rotation: .init(), translation: .zero)
                    hitEntity.move(to: largerTransform, relativeTo: hitEntity.parent, duration: 0.2)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        hitEntity.move(to: origTransform, relativeTo: hitEntity.parent, duration: 0.2)
                    }
                case .failure:
                    print("could not get access to entity")
                }
            }
        } else if let result = arView.raycast(
            from: touchInView,
            allowing: .existingPlaneGeometry, alignment: .horizontal
        ).first {
            self.addNewAnchor(transform: result.worldTransform)
        }
    }
    
    //     TODO: -- Fix this function ???
    //    / Add a new anchor to the session
    //    / - Parameter transform: position in world space where the new anchor should be
    func addNewAnchor(transform: simd_float4x4) {
        guard let usdzModel = self.usdzModel else {
            print("Error: No model URL provided")
            return
        }
        
        do {
            //            let arAnchor = ARAnchor(name: "Cube Anchor", transform: transform)
            //            let newAnchor = AnchorEntity(anchor: arAnchor)
            //
            //            let cubeModel = ModelEntity(
            //                mesh: .generateBox(size: 0.1),
            //                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            //            )
            //            cubeModel.generateCollisionShapes(recursive: false)
            //            arView.installGestures([.all], for: cubeModel)
            //            
            //            newAnchor.addChild(cubeModel)
            //
            //            newAnchor.synchronization?.ownershipTransferMode = .autoAccept
            //
            //            newAnchor.anchoring = AnchoringComponent(arAnchor)
            //            arView.scene.addAnchor(newAnchor)
            //            arView.session.add(anchor: arAnchor)
            
            let entity = try ModelEntity.loadModel(contentsOf: usdzModel, withName: usdzModel.lastPathComponent)
            entity.generateCollisionShapes(recursive: true)
            entity.transform.scale = simd_float3(0.01, 0.01, 0.01)
            
            for anim in entity.availableAnimations {
                entity.playAnimation(anim.repeat(duration: .infinity), transitionDuration: 1.25, startsPaused: false)
            }
            
            let arAnchor = ARAnchor(name: "Entity Anchor", transform: transform)
            let anchorEntity = AnchorEntity(anchor: arAnchor)
            anchorEntity.addChild(entity)
            
            arView.installGestures([.all], for: entity)
            anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
            anchorEntity.anchoring = AnchoringComponent(arAnchor)
            
            arView.scene.addAnchor(anchorEntity)
            arView.session.add(anchor: arAnchor)
        } catch {
            print("Error: Failed to load entity from URL \(usdzModel): \(error)")
        }
    }
}

