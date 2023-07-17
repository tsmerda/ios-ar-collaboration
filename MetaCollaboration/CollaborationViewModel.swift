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

enum activeAppMode {
    case none
    case onlineMode
    case offlineMode
}

//enum activeARMode {
//    case recognitionMode
//    case collaborationMode
//}

class CollaborationViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var appMode: activeAppMode = activeAppMode.none
    //    @Published var arMode: activeARMode = activeARMode.recognitionMode
    @Published var mlModel: VNCoreMLModel?
    @Published var usdzModel: URL?
    @Published var referenceObjects = Set<ARReferenceObject>()
    @Published var ARResults: String = "Currently no object recognized"
    @Published var assetsDownloadingCount = 0
    @Published var downloadedAssets: [String] = []
    @Published var selectedAssets: [String] = []
    @Published var guideList: [Guide]? /// = MockGuideList
    @Published var assetList: [Asset]? /// = MockAssetList
    @Published var currentGuide: ExtendedGuide?
    @Published var uniqueID = UUID()
    var showingSheet: Binding<Bool>?
    
    //    @Published var currentStep: Int = 0
    
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
        if let storedAppMode = UserDefaults.standard.string(forKey: "appMode") {
            if storedAppMode == "onlineMode" {
                appMode = activeAppMode.onlineMode
            }
            if storedAppMode == "offlineMode" {
                appMode = activeAppMode.offlineMode
            }
        }
        
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
                let assetNameWithoutExtension = assetUrl.deletingPathExtension().lastPathComponent
                
                // Select model if it's not in selectedAssets array
                if !selectedAssets.contains(assetNameWithoutExtension) {
                    print("\(String(describing: self.currentGuide?.objectSteps?[0].objectName)) -- \(assetNameWithoutExtension)")
                    if assetUrl.pathExtension == "arobject" {
                        // Insert ARObject into referenceObjects Set for 3D objects detection
                        selectModel(assetName: assetName)
                    } else if assetUrl.pathExtension == "mlmodel" {
                        // Select MLModel for detector
                        selectModel(assetName: assetName)
                    } else if currentGuide?.objectSteps?[0].objectName == assetNameWithoutExtension {
                        // Select USDZ model for initial step of guide
                        selectModel(assetName: assetName)
                        return
                    }
                }
            }
        }
    }
    
    // TODO: -- upravit vybirani USDZ modelu v zavislosti na aktualnim stepu
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
                        if assetExtension == "usdz" {
                            self.usdzModel = fileURL
                        } else if assetExtension == "arobject" {
                            let referenceObject = try ARReferenceObject(archiveURL: fileURL)
                            referenceObjects.insert(referenceObject)
                        } else if assetExtension == "mlmodel" {
                            let compiledUrl = try MLModel.compileModel(at: fileURL)
                            self.mlModel = try VNCoreMLModel(for: MLModel(contentsOf: compiledUrl))
                        }
                        
                        if let index = selectedAssets.firstIndex(where: { $0.hasSuffix(".\(assetExtension)") }) {
                            selectedAssets.remove(at: index)
                        }
                        
                        self.selectedAssets.append(assetName)
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
    
    
    // MARK: - Network methods
    
    // ========
    // In offline mode, client download all the ML and USDZ models within guides to be able to use an AR and collaborative experience
    // In online mode, is not necessary to download all assets at once instead there is ongoing communication with the backend all the time.
    // ========
    
    // Get list of all guides
    func getAllGuides() {
        self.networkService.getAllGuides() { result in
            switch result {
            case .success(let value):
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
                                print(value)
                self.currentGuide = value
                
                // TODO: - Po testovani odstranit
                self.getAssetByName(assetName: "r2d2")
                self.getAssetByName(assetName: "arrow")
//                self.getAssetByName(assetName: "sneaker_airforce")
                
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
                
                // Save ExtendedGuide downloaded model into local storage
                let defaults = UserDefaults.standard
                if let encodedGuide = try? JSONEncoder().encode(value) {
                    defaults.set(encodedGuide, forKey: "downloadedGuide")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Download asset by name
    func getAssetByName(assetName: String) {
        print("Downloading of asset: \(assetName)")
        
        self.networkService.getAssetByName(assetName: assetName, loadingCallback: { isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self.assetsDownloadingCount += 1
                } else {
                    self.assetsDownloadingCount -= 1
                }
            }
        }, completion: { result in
            switch result {
            case .success(let value):
                //                print("Completition network \(value)")
                self.updateDownloadedAssets(assetName: value)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    // Remove guide and all downloaded models from device
    func removeDatasetFromLocalStorage() {
        currentGuide = nil
        downloadedAssets.removeAll()
        selectedAssets.removeAll()
        mlModel = nil
        ARResults = "Currently no model available"
        
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
}
