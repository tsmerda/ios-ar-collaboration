//
//  ContentView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    @State private var showingSheet = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
                    .scaleEffect(1.5)
                    .zIndex(2)
            }
            
            TabView {
                if UserDefaults.standard.string(forKey: "appMode") != "onlineMode" {
                    DatasetListView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("Menu", systemImage: "list.dash")
                        }
                }
                
                ZStack(alignment: .center) {
                    if viewModel.arMode == activeARMode.recognitionMode {
                        CollaborationView()
                            .environmentObject(viewModel)
                            .zIndex(1)
                            .sheet(isPresented: $showingSheet) {
                                GuideView(guide: $viewModel.currentGuide)
                                    .environmentObject(viewModel)
                            }
                    } else {
                        ARViewContainer()
                            .environmentObject(viewModel)
                            .zIndex(1)
                            .sheet(isPresented: $showingSheet) {
                                GuideView(guide: $viewModel.currentGuide)
                                    .environmentObject(viewModel)
                            }
                    }
                    
                    if viewModel.arMode == activeARMode.recognitionMode {
                        VStack {
                            Button(action: {
                                self.showingSheet = true
                            }) {
                                HStack {
                                    Text(viewModel.ARResults)
                                        .font(.title3)
                                        .multilineTextAlignment(.leading)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer ()
                                }
                                .padding(.leading, 30)
                            }
                            .frame(width: UIScreen.main.bounds.width - 15, height: 70)
                            .background(.white)
                            .padding(.top, 30)
                            
                            Spacer()
                        }
                        .zIndex(2)
                    } else {
                        VStack {
                            HStack {
                                VStack {
                                    ForEach(viewModel.multipeerSession?.peerDisplayNames ?? [], id: \.self) { displayName in
                                        Text(displayName)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.arMode = activeARMode.recognitionMode
                                }) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color.white)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "xmark")
                                                .foregroundColor(.black)
                                        )
                                }
                                .padding(.top, 15)
                                .padding(.trailing, 15)
                            }
                            
                            Spacer()
                        }
                        .zIndex(2)
                    }
                }
                .tabItem {
                    Label("Collaboration", systemImage: "viewfinder")
                }
                
                InfoView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
            }
        }
        .onAppear() {
            viewModel.getGuideById(id: "640b700f16cde6145a3bfc19")
        }
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
