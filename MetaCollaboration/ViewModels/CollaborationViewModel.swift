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
    @Published var downloadedGuides: [ExtendedGuide] = [] {
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
    @Published var currentGuide: ExtendedGuide?
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
        initDownloadedGuides()
        // Check downloaded assets saved in device local storage and add into downloadedAssets
        initDownloadedAssets()
    }
    
    // MARK: - Public Methods
    
    func loadReferenceObjects(_ assetName: String) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for fileURL in fileURLs {
                //            TODO: - Resolve: failed to setup referenceObjects nilError
                if fileURL.pathExtension == "arobject" && fileURL.lastPathComponent == assetName {
                    let referenceObject = try ARReferenceObject(archiveURL: fileURL)
                    referenceObjects.insert(referenceObject)
                }
            }
        } catch {
            // TODO: hodit do alert modalu
            print("Failed to set up referenceObjects: \(error)")
        }
    }
    
    func refreshCollaborationView() {
        // TODO: - Opravit nastaveni UUID() -> zpusobovalo seknuti pri prejiti na ARView
        //        self.uniqueID = UUID()
    }
    
    // Remove guide and all downloaded models from device
    func removeAllFromLocalStorage() {
        print(referenceObjects)
        //    TODO: ARObject zustava inicializovany => resetovat AR session nebo colaboration view
        currentGuide = nil
        referenceObjects.removeAll()
        downloadedAssets.removeAll()
        downloadedGuides.removeAll()
    }
    
    //    TODO: - as extension
    func removeAssetsFromDevice() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "arobject" {
                    try FileManager.default.removeItem(at: fileURL)
                    print("Model \(fileURL) removed")
                }
            }
        } catch { print(error) }
    }
    
    func initDownloadedGuides() {
        downloadedGuides = readGuidesFromJSON()
    }
    
    func initDownloadedAssets() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if !downloadedAssets.contains(fileURL.lastPathComponent) {
                    downloadedAssets.append(fileURL.lastPathComponent)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func isGuideIdDownloaded(_ id: String) -> Bool {
        return self.downloadedGuides.contains { item in
            item.id == id
        }
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
            //            self.updateDownloadedAssets(assetName: downloadedAsset)
            
            self.networkState = .success
        } catch {
            self.networkState = .failed(error: error)
            self.hasError = true
        }
    }
}
