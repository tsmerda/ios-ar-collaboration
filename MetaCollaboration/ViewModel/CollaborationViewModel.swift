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

class CollaborationViewModel: ObservableObject {
    // MARK: - Properties
    
    //    @Published var usdzModel: URL?
    @Published var referenceObjects = Set<ARReferenceObject>()
    @Published var assetsDownloadingCount = 0
    @Published var downloadedAssets: [String] = []
//    @Published var selectedAssets: [String] = []
    @Published var guideList: [Guide]? /// = MockGuideList
    @Published var assetList: [Asset]? /// = MockAssetList
    @Published var currentGuide: ExtendedGuide?
    @Published var uniqueID = UUID()
    
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    // TODO: - je tohle potreba?
    var showStepSheet: Binding<Bool>?
    
    private var networkManager: NetworkManager
    
    // MARK: Collaboration properties
    
    @Published var arView: ARView!
    @Published var multipeerSession: MultipeerSession?
    @Published var sessionIDObservation: NSKeyValueObservation?
    
    // A dictionary to map MultiPeer IDs to ARSession ID's.
    // This is useful for keeping track of which peer created which ARAnchors.
    var peerSessionIDs = [MCPeerID: String]()
    
    // MARK: - Initialization
    
    convenience init() {
        self.init(networkManager: NetworkManager())
    }
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        
        // Check downloaded guide saved in UserDefaults and add into currentGuide
        guideAlreadyDownloaded()
        // Check downloaded assets saved in device local storage and add into downloadedAssets
        assetAlreadyDownloaded()
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
//        selectedAssets.removeAll()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "downloadedGuide")
        
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
    
    func guideAlreadyDownloaded() {
        if let downloadedGuideData = UserDefaults.standard.data(forKey: "downloadedGuide") {
            let decoder = JSONDecoder()
            if let downloadedGuide = try? decoder.decode(ExtendedGuide.self, from: downloadedGuideData) {
                self.currentGuide = downloadedGuide
            }
        }
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
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - Network methods
    
    // ========
    // In offline mode, client download all the ML and USDZ models within guides to be able to use an AR and collaborative experience
    // In online mode, is not necessary to download all assets at once instead there is ongoing communication with the backend all the time.
    // ========
    
    // Get list of all guides
    func getAllGuides() {
        isLoading = true
        
        NetworkManager.shared.getAllGuides { [self] result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let guides):
                    self.guideList = guides
                    
                case .failure(let error):
                    switch error {
                    case .invalidData:
                        self.alertItem = AlertContext.invalidData
                    case .invalidURL:
                        self.alertItem = AlertContext.invalidURL
                    case .invalidResponse:
                        self.alertItem = AlertContext.invalidResponse
                    case .unableToComplete:
                        self.alertItem = AlertContext.unableToComplete
                    }
                }
            }
        }
    }
    
    // Get guide by ID
    func getGuideById(id: String) {
        isLoading = true
        
        NetworkManager.shared.getGuideById(guideId: id) { [self] result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let guide):
                    self.currentGuide = guide
                    
                    // TODO: - Po testovani odstranit
                    self.getAssetByName(assetName: "r2d2")
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
                    
                    // TODO: - Is it necessary to save into UserDefaults?
                    // Save ExtendedGuide downloaded model into local storage
                    let defaults = UserDefaults.standard
                    if let encodedGuide = try? JSONEncoder().encode(guide) {
                        defaults.set(encodedGuide, forKey: "downloadedGuide")
                    }
                    
                case .failure(let error):
                    switch error {
                    case .invalidData:
                        self.alertItem = AlertContext.invalidData
                    case .invalidURL:
                        self.alertItem = AlertContext.invalidURL
                    case .invalidResponse:
                        self.alertItem = AlertContext.invalidResponse
                    case .unableToComplete:
                        self.alertItem = AlertContext.unableToComplete
                    }
                }
            }
        }
    }
    
    // Download asset by name
    func getAssetByName(assetName: String) {
        //        isLoading = true
        
        NetworkManager.shared.getAssetByName(assetName: assetName, loadingCallback: { isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self.assetsDownloadingCount += 1
                } else {
                    self.assetsDownloadingCount -= 1
                }
            }
        }, completion: { [self] result in
            DispatchQueue.main.async {
                //                self.isLoading = false
                
                switch result {
                case .success(let asset):
                    self.updateDownloadedAssets(assetName: asset)
                    
                case .failure(let error):
                    switch error {
                    case .invalidData:
                        self.alertItem = AlertContext.invalidData
                    case .invalidURL:
                        self.alertItem = AlertContext.invalidURL
                    case .invalidResponse:
                        self.alertItem = AlertContext.invalidResponse
                    case .unableToComplete:
                        self.alertItem = AlertContext.unableToComplete
                    }
                }
            }
        })
    }
}
