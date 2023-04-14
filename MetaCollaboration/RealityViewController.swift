//
//  RealityViewController.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 28.01.2023.
//

import ARKit
import MultipeerConnectivity
import RealityKit
import MultipeerHelper

class RealityViewController: UIViewController, ARSessionDelegate {
    let arView = ARView(frame: .zero)
    //  let focusSquare = FESquare()
    var usdzModel: URL?
    var multipeerHelp: MultipeerHelper!
    required init() {
        super.init(nibName: nil, bundle: nil)
        setupARView()
        setupMultipeer()
        setupGestures()
        
        // Do not synchronize this entity
        //    focusSquare.synchronization = nil
        //    focusSquare.viewDelegate = arView
        //    focusSquare.setAutoUpdate(to: true)
    }
    
    func setupARView() {
        arView.frame = view.bounds
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        arView.session.delegate = self
        
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        arConfiguration.isCollaborationEnabled = true
        arView.session.run(arConfiguration, options: [])
        view.addSubview(arView)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetSession() {
        usdzModel = nil
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension RealityViewController: MultipeerHelperDelegate {
    
    func shouldSendJoinRequest(
        _ peer: MCPeerID,
        with discoveryInfo: [String: String]?
    ) -> Bool {
        if RealityViewController.checkPeerToken(with: discoveryInfo) {
            return true
        }
        print("incompatible peer!")
        return false
    }
    
    func setupMultipeer() {
        multipeerHelp = MultipeerHelper(
            serviceName: "helper-test",
            sessionType: .both,
            delegate: self
        )
        
        // MARK: - Setting RealityKit Synchronization
        
        guard let syncService = multipeerHelp.syncService else {
            fatalError("could not create multipeerHelp.syncService")
        }
        arView.scene.synchronizationService = syncService
    }
    
    func receivedData(_ data: Data, _ peer: MCPeerID) {
        print(String(data: data, encoding: .unicode) ?? "Data is not a unicode string")
    }
    
    func peerJoined(_ peer: MCPeerID) {
        print("new peer has joined: \(peer.displayName)")
    }
}
