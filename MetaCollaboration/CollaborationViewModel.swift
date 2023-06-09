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
    @Published var ARResults: String = "Currently no object recognized"
    @Published var assetsDownloadingCount = 0
    @Published var downloadedAssets: [String] = []
    @Published var selectedAssets: [String] = []
    @Published var guideList: [Guide]? /// = MockGuideList
    @Published var assetList: [Asset]? /// = MockAssetList
    @Published var currentGuide: ExtendedGuide?
    @Published var uniqueID = UUID()
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
        
        // Check downloaded and assets saved in device local storage and add into downloadedAssets array
        guideAlreadyDownloaded()
        // Check downloaded and assets saved in device local storage and add into downloadedAssets array
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
                    if assetUrl.pathExtension == "mlmodel" {
                        // Select MLModel for detector
                        selectModel(assetName: assetName, initial: true)
                    } else if currentGuide?.objectSteps?[0].objectName == assetNameWithoutExtension {
                        // Select USDZ model for initial step of guide
                        selectModel(assetName: assetName, initial: true)
                        return
                    }
                }
            }
        }
    }
    
    // TODO: -- upravit vybirani USZD modelu v zavislosti na aktualnim stepu
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
    
    func refreshCollaborationView() {
        self.uniqueID = UUID()
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
                
                // TODO: -- NA BACKENDU SE MUSI NASTAVIT CAMELCASE!!!! (objectName misto object_name atd...) + pridat parametr pro detector model
                self.getAssetByName(assetName: "YOLOv3")
                
                if let objectSteps = value.objectSteps {
                    for objectStep in objectSteps {
                        if let objectName = objectStep.objectName {
                            // Download models based on objectName from guideStep
                            self.getAssetByName(assetName: objectName)
                        }
                    }
                }
                
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
        defaults.removeObject(forKey: "selectedAssets")
        
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
                print(fileURL.lastPathComponent)
                updateDownloadedAssets(assetName: fileURL.lastPathComponent)
            }
        } catch {
            print(error)
        }
    }
}
