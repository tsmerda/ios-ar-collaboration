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

import ARKit
import SwiftUI
import RealityKit
import MultipeerConnectivity


enum ActiveAppMode: String {
    case none
    case onlineMode
    case offlineMode
}

enum NetworkState {
    case na
    case loading
    case success
    case failed(error: Error)
}


class CollaborationViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var referenceObjects = Set<ARReferenceObject>()
    @Published var downloadedAssets: [String] = [] {
        didSet {
            // Save downloadedAssets locally or delete it
            if !downloadedAssets.isEmpty {
                if let lastAddedElement = downloadedAssets.last {
                    loadReferenceObjects(lastAddedElement)
                }
            } else {
                removeAssetsFromDevice()
            }
        }
    }
    @Published var downloadedGuides: [ExtendedGuideResponse] = [] {
        didSet {
            // Save downloadedGuides locally to JSON or delete JSON
            if !downloadedGuides.isEmpty {
                saveGuidesToJSON(downloadedGuides)
            } else {
                deleteGuidesJSON()
            }
        }
    }
    @Published var guideList: [Guide]?
    @Published var currentGuide: ExtendedGuideResponse? = ExtendedGuideResponse.example
    @Published var currentStep: ObjectStep?
    @Published var uniqueID = UUID()
    
    @Published private(set) var networkState: NetworkState = .na
    @Published var hasError: Bool = false
    
    // MARK: Collaboration properties
    
    @Published var arView: ARView!
    @Published var multipeerSession: MultipeerSession?
    @Published var sessionIDObservation: NSKeyValueObservation?
    
    // TODO: - je tohle potreba?
    var showStepSheet: Binding<Bool>?
    
    // A dictionary to map MultiPeer IDs to ARSession ID's.
    // This is useful for keeping track of which peer created which ARAnchors.
    var peerSessionIDs = [MCPeerID: String]()
    
    let jsonDataFile = "guidesData.json"
    
    // MARK: - Initialization
    
    init() {
        // Check downloaded guide saved in UserDefaults and add into currentGuide
        downloadedGuides = readGuidesFromJSON()
        // Check downloaded assets saved in device local storage and add into downloadedAssets
        initDownloadedAssets()
    }
    
    // MARK: - Public Methods
    func refreshCollaborationView() {
        // TODO: - Opravit nastaveni UUID() -> zpusobovalo seknuti pri prejiti na ARView
        //        self.uniqueID = UUID()
    }
    
    // Remove guide and all downloaded models from device
    func removeAllFromLocalStorage() {
        //    TODO: ARObject zustava inicializovany => resetovat AR session nebo colaboration view
        currentGuide = nil
        referenceObjects.removeAll()
        downloadedAssets.removeAll()
        downloadedGuides.removeAll()
    }
    
    func isGuideIdDownloaded(_ id: String) -> Bool {
        return self.downloadedGuides.contains { item in
            item.id == id
        }
    }
    
    func downloadedGuideById(_ id: String) -> ExtendedGuideResponse? {
        if let guide = self.downloadedGuides.first(where: { $0.id == id }) {
            return guide
        }
        return nil
    }
    
    func setCurrentGuide(_ id: String) {
        if let guide = self.downloadedGuides.first(where: { $0.id == id }) {
            self.currentGuide = guide
        }
    }
    
    // MARK: - Network methods
    
    // ========
    // In offline mode, client download all the ML and USDZ models within guides to be able to use an AR and collaborative experience
    // In online mode, is not necessary to download all assets at once instead there is ongoing communication with the backend all the time.
    // ========
    
    // Get list of all guides
    @MainActor
    func getAllGuides() async {
        self.networkState = .loading
        self.hasError = false
        
        do {
            self.guideList = try await NetworkManager.shared.getAllGuides()
            self.networkState = .success
        } catch {
            self.networkState = .failed(error: error)
            self.hasError = true
        }
    }
    
    // Get guide by ID
    @MainActor
    func getGuideById(id: String) async {
        self.networkState = .loading
        self.hasError = false
        
        do {
            let guide = try await NetworkManager.shared.getGuideById(guideId: id)
            downloadedGuides.append(guide)
            // TODO: - nastavi se po spusteni daneho guide, kdy se vybere z downloadedGuides
            // self.currentGuide = guide
            
            // TODO: - Implementovat stazeni vsech modelu, ktere jsou v danym <guide>
            await self.getAssetByName(assetName: "r2d2")
            
            // Download all assets related to guide steps
            //                if let objectSteps = value.objectSteps {
            //                    for objectStep in objectSteps {
            //                        if let objectName = objectStep.objectName {
            //                            // Download models based on objectName from guideStep
            //                            self.getAssetByName(assetName: objectName)
            //                        }
            //                    }
            //                }
            
            self.networkState = .success
        } catch {
            self.networkState = .failed(error: error)
            self.hasError = true
        }
    }
    
    @MainActor
    func getStepById(_ guideId: String, _ objectStepOrder: Int) async {
        self.networkState = .loading
        self.hasError = false
        
        do {
            self.currentStep = try await NetworkManager.shared.getStepById(guideId: guideId, objectStepOrder: objectStepOrder)
            self.networkState = .success
        } catch {
            self.networkState = .failed(error: error)
            self.hasError = true
        }
    }
    
    // Download asset by name
    @MainActor
    func getAssetByName(assetName: String) async {
        self.networkState = .loading
        self.hasError = false
        
        do {
            let downloadedAsset = try await NetworkManager.shared.getAssetByName(assetName: assetName)
            if !downloadedAssets.contains(downloadedAsset) {
                downloadedAssets.append(downloadedAsset)
            }
            
            self.networkState = .success
        } catch {
            self.networkState = .failed(error: error)
            self.hasError = true
        }
    }
}
