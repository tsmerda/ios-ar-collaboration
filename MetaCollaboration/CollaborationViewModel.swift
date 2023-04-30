//
//  CollaborationViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit

import SwiftUI
import RealityKit
import ARKit
import MultipeerConnectivity

enum activeAppMode {
    case none
    case onlineMode
    case offlineMode
}

enum activeARMode {
    case recognitionMode
    case collaborationMode
}

class CollaborationViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var appMode: activeAppMode = .none
    @Published var arMode: activeARMode = .recognitionMode
    @Published var mlModel: VNCoreMLModel?
    @Published var usdzModel: URL?
    @Published var ARResults: String = "Currently no model available"
    @Published var isLoading = false
    //    @Published var selectedDataset: String = "" // not necessary
    //    @Published var datasetList: [Dataset] = MockDatasetList // not necessary
    @Published var downloadedAssets: [String] = []
    @Published var selectedAssets: [String] = []
    @Published var guideList: [Guide]? = MockGuideList
    @Published var assetList: [Asset]? = MockAssetList
    @Published var currentGuide: Guide?
    
    private var networkService: NetworkService
    
    // MARK: Collaboration properties
    
    @Published var arView: ARView!
    @Published var multipeerSession: MultipeerSession?
    @Published var sessionIDObservation: NSKeyValueObservation?
    
    // A dictionary to map MultiPeer IDs to ARSession ID's.
    // This is useful for keeping track of which peer created which ARAnchors.
    var peerSessionIDs = [MCPeerID: String]()
    
    // MARK: - Initialization
    
    convenience init() {
        self.init(networkService: NetworkService())
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        guard let storedAppMode = UserDefaults.standard.string(forKey: "appMode") else {
            return
        }
        
        if storedAppMode == "none" {
            appMode = activeAppMode.none
        }
        if storedAppMode == "onlineMode" {
            appMode = activeAppMode.onlineMode
        }
        if storedAppMode == "offlineMode" {
            appMode = activeAppMode.offlineMode
        }
        
        if let selectedAssets = UserDefaults.standard.array(forKey: "selectedAssets") as? [String] {
            self.selectedAssets = selectedAssets
            
            for asset in selectedAssets {
                selectModel(assetName: asset, initial: true)
            }
        }
        
        //    TODO: -- implementation
        if appMode == .offlineMode {
            getAllGuides()
            getAllAssets()
            assetAlreadyDownloaded()
            //            getGuideById(id: "640b700f16cde6145a3bfc19")
        }
    }
    
    // MARK: -- Initialize collaboration UIView
    func initializeARViewContainer() {
        arView = ARView(frame: .zero)
        
        // Turn off ARView's automatically-configured session
        // to create and set up your own configuration.
        arView.automaticallyConfigureSession = false
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        // Enable a collaborative session.
        config.isCollaborationEnabled = true
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        // Begin the session.
        arView.session.run(config)
        
        // Setup a coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        
        arView.addSubview(coachingOverlay)
        
        // Use key-value observation to monitor your ARSession's identifier.
        sessionIDObservation = arView.session.observe(\.identifier, options: [.new]) { object, change in
            print("SessionID changed to: \(change.newValue!)")
            // Tell all other peers about your ARSession's changed ID, so
            // that they can keep track of which ARAnchors are yours.
            guard let multipeerSession = self.multipeerSession else { return }
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        
        // Start looking for other players via MultiPeerConnectivity.
        multipeerSession = MultipeerSession(receivedDataHandler: self.receivedData, peerJoinedHandler: self.peerJoined, peerLeftHandler: peerLeft, peerDiscoveredHandler: peerDiscovered)
        
        // Inicializace gest pro modifikaci scény a modelů
        arView.gestureSetup()
    
        
        // ADD REAL-TIME SYNCHRONIZATION
        guard let multipeerConnectivityService =
          multipeerSession!.multipeerConnectivityService else {
            fatalError("[FATAL ERROR] Unable to create Sync Service!")
          }
        arView.scene.synchronizationService = multipeerConnectivityService
    }
    
    // MARK: - Public Methods
    
    func updateDownloadedAssets(assetName: String) {
        if !downloadedAssets.contains(assetName) {
            DispatchQueue.main.async {
                self.downloadedAssets.append(assetName)
            }
        }
    }
    
    func selectModel(assetName: String, initial: Bool) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.lastPathComponent == assetName {
                    
                    let assetExtension = URL(fileURLWithPath: assetName).pathExtension
                    
                    do {
                        if assetExtension == "usdz" {
                            self.usdzModel = fileURL
                        } else {
                            let compiledUrl = try MLModel.compileModel(at: fileURL)
                            self.mlModel = try VNCoreMLModel(for: MLModel(contentsOf: compiledUrl))
                        }
                        
                        if let index = selectedAssets.firstIndex(where: { $0.hasSuffix(".\(assetExtension)") }) {
                            selectedAssets.remove(at: index)
                        }
                        
                        self.selectedAssets.append(assetName)
                        
                        if !initial {
                            saveSelectedAssets()
                        }
                        
                    } catch {
                        print(error)
                    }
                }
            }
        } catch { print(error) }
    }
    
    func saveSelectedAssets() {
        let defaults = UserDefaults.standard
        defaults.set(selectedAssets, forKey: "selectedAssets")
    }
    
    
    // MARK: - Network methods
    
    // ========
    // In offline mode, client download all the ML models and guides to be able to use an AR experience
    // In online mode, is not necessary to download all at once instead there is ongoing communication with the backend all the time.
    // ========
    
    // Send photo to BE and get array of results.
    func getResultsByImage(image: String) {
        //        byteArray
    }
    
    // Get all ML models
    func getAllMLModels() {}
    
    // Get list of all guides
    func getAllGuides() {
        self.networkService.getAllGuides() { result in
            switch result {
            case .success(let value):
//                print(value)
                self.guideList = value
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Get guide by ID
    func getGuideById(id: String) {
        self.networkService.getGuideById(guideId: id) { result in
            switch result {
            case .success(let value):
//                print(value)
                self.currentGuide = value
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Get all assets
    func getAllAssets() {
        self.networkService.getAllAssets() { result in
            switch result {
            case .success(let value):
//                print(value)
                self.assetList = value
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Download asset by name
    func getAssetByName(assetName: String) {
        self.networkService.getAssetByName(assetName: assetName) { result in
            switch result {
            case .success():
//                print("Asset downloaded: \(assetName)")
                self.updateDownloadedAssets(assetName: assetName)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Remove all downloaded models
    func removeModelsFromLocalStorage() {
        downloadedAssets.removeAll()
        selectedAssets.removeAll()
        mlModel = nil
        ARResults = "Currently no model available"
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                //          if fileURL.pathExtension == "usdz" {
                try FileManager.default.removeItem(at: fileURL)
                print("Model \(fileURL) removed")
                //          }
            }
        } catch { print(error) }
    }
    
    func assetAlreadyDownloaded() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                updateDownloadedAssets(assetName: fileURL.lastPathComponent)
            }
        } catch { print(error) }
    }
}

// MARK: -- MultipeerSession handlers

extension CollaborationViewModel {
    private func sendARSessionIDTo(peers: [MCPeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        let idString = arView.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }
    
    func receivedData(_ data: Data, from peer: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            arView.session.update(with: collaborationData)
            return
        }
        // ...
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                        offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            if let oldSessionID = peerSessionIDs[peer] {
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            peerSessionIDs[peer] = newSessionID
        }
    }
    
    func peerDiscovered(_ peer: MCPeerID) -> Bool {
        guard let multipeerSession = multipeerSession else { return false }
        
        if multipeerSession.connectedPeers.count > 4 {
            // Do not accept more than four users in the experience.
            print("A fifth peer wants to join the experience.\nThis app is limited to four users.")
            return false
        } else {
            return true
        }
    }
    
    func peerJoined(_ peer: MCPeerID) {
        print("""
            A peer wants to join the experience.
            Hold the phones next to each other.
            """)
        // Provide your session ID to the new user so they can keep track of your anchors.
        sendARSessionIDTo(peers: [peer])
    }
    
    func peerLeft(_ peer: MCPeerID) {
        print("A peer has left the shared experience.")
        
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = arView.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                arView.session.remove(anchor: anchor)
            }
        }
    }
}
