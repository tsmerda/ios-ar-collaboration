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
    
    //    @Published var usdzModel: URL?
    @Published var referenceObjects = Set<ARReferenceObject>()
    @Published var assetsDownloadingCount = 0
    @Published var downloadedAssets: [String] = [] {
        didSet {
//        TODO: - Zpracovat stejne jako downloadedGuides
            // Save downloadedAssets locally or delete it
            if !downloadedAssets.isEmpty {
//                saveGuidesToJSON(downloadedGuides)
            } else {
//                deleteGuidesJSON()
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
    //    @Published var selectedAssets: [String] = []
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
    func updateDownloadedAssets(assetName: String) {
        if !downloadedAssets.contains(assetName) {
            DispatchQueue.main.async { [self] in
                downloadedAssets.append(assetName)
                
                // Get asset name without extension
                let assetUrl = URL(fileURLWithPath: assetName)
                //                let assetNameWithoutExtension = assetUrl.deletingPathExtension().lastPathComponent
                
                if assetUrl.pathExtension == "arobject" {
                    // Insert ARObject into referenceObjects Set for 3D objects detection
                    selectModel(assetName: assetName)
                }
                
                //                // Select model if it's not in selectedAssets array
                //                if !selectedAssets.contains(assetNameWithoutExtension) {
                //                    //                    print("\(String(describing: self.currentGuide?.objectSteps?[0].objectName)) -- \(assetNameWithoutExtension)")
                //                    if assetUrl.pathExtension == "arobject" {
                //                        // Insert ARObject into referenceObjects Set for 3D objects detection
                //                        selectModel(assetName: assetName)
                //                    }
                //                }
            }
        }
    }
    
    func selectModel(assetName: String) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.lastPathComponent == assetName {
                    
                    let assetExtension = URL(fileURLWithPath: assetName).pathExtension
                    
                    do {
                        if assetExtension == "arobject" {
                            let referenceObject = try ARReferenceObject(archiveURL: fileURL)
                            referenceObjects.insert(referenceObject)
                        }
                        
                        //                    TODO: Proc tato funkce ??
                        //                        if let index = selectedAssets.firstIndex(where: { $0.hasSuffix(".\(assetExtension)") }) {
                        //                            selectedAssets.remove(at: index)
                        //                        }
                        //
                        //                        self.selectedAssets.append(assetName)
                    } catch {
                        print(error)
                    }
                }
            }
        } catch { print(error) }
    }
    
    func refreshCollaborationView() {
        // TODO: -- Opravit nastaveni UUID() -> zpusobovalo seknuti pri prejiti na ARView
        //        self.uniqueID = UUID()
    }
    
    // Remove guide and all downloaded models from device
    func removeDatasetFromLocalStorage() {
        //    TODO: ARObject zustava inicializovany => resetovat AR session nebo colaboration view
        currentGuide = nil
        downloadedAssets.removeAll()
        print(downloadedGuides)
        downloadedGuides.removeAll()
        print(downloadedGuides)
        
        //    TODO: !!!!! _______
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
                print("Model \(fileURL) removed")
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
                updateDownloadedAssets(assetName: fileURL.lastPathComponent)
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
            //            TODO: - nastavi se po spusteni daneho guide !!!
            //                self.currentGuide = guide
            
            // TODO: - Po testovani odstranit
            await self.getAssetByName(assetName: "r2d2")
            //                    self.getAssetByName(assetName: "arrow")
            
            // TODO: -- Implementovat stazeni vsech modelu a na zaklade modelu pod danym Guide, vypsat do detailu Guide?
            
            // Download all assets related to guide steps
            //                if let objectSteps = value.objectSteps {
            //                    for objectStep in objectSteps {
            //                        if let objectName = objectStep.objectName {
            //                            // Download models based on objectName from guideStep
            //                            self.getAssetByName(assetName: objectName)
            //                        }
            //                    }
            //                }
            
            downloadedGuides.append(guide)
//            saveGuideToJSON(guides: downloadedGuides)
            
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
            self.updateDownloadedAssets(assetName: downloadedAsset)
            
            self.networkState = .success
        } catch {
            self.networkState = .failed(error: error)
            self.hasError = true
        }
    }
}
