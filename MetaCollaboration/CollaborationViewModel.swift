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

enum activeAppMode {
    case none
    case onlineMode
    case offlineMode
}

class CollaborationViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var appMode: activeAppMode = .none
    @Published var mlModel: VNCoreMLModel?
    @Published var ARResults: String = "Currently no model available"
    @Published var isLoading = false
    //    @Published var selectedDataset: String = "" // not necessary
    //    @Published var datasetList: [Dataset] = MockDatasetList // not necessary
    @Published var downloadedAssets: [String] = []
    @Published var guideList: [Guide]? = MockGuideList
    @Published var assetList: [Asset]? = MockAssetList
    @Published var currentGuide: Guide?
    @Published var selectedAssets: [String] = []
    
    private var networkService: NetworkService
    
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
        
        //    TODO: -- implementation
        if appMode == .offlineMode {
            //            getAllMLModels()
            //            getGuideById(id: "640b700f16cde6145a3bfc19")
            //            getAssetByName(assetName: "sneaker_airforce")
            getAllGuides()
            getAllAssets()
            assetAlreadyDownloaded()
            //            removeModelsFromLocalStorage()
        }
    }
    
    // MARK: - Public Methods
    
    func updateDownloadedAssets(assetName: String) {
        if !downloadedAssets.contains(assetName) {
            DispatchQueue.main.async {
                self.downloadedAssets.append(assetName)
            }
        }
    }
    
    func selectMLModel(assetName: String) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.lastPathComponent == assetName {
                    do {
                        let compiledUrl = try MLModel.compileModel(at: fileURL)
                        self.mlModel = try VNCoreMLModel(for: MLModel(contentsOf: compiledUrl))
                        
                        let assetExtension = URL(fileURLWithPath: assetName).pathExtension
                        
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
                print(value)
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
                print(value)
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
                print("Asset downloaded: \(assetName)")
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


// Download selected Dataset
//func download(_ modelUrl: String) {
//    isLoading = true
//
//    let url = URL(string: modelUrl)!
//    let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//    let savedURL = documentsURL.appendingPathComponent(url.lastPathComponent)
//
//    DispatchQueue.global(qos: .userInitiated).async {
//        if FileManager.default.fileExists(atPath: savedURL.path) {
//            // model is already downloaded
//            do {
//                let compiledUrl = try MLModel.compileModel(at: savedURL)
//                let result = Result {
//                    try VNCoreMLModel(for: MLModel(contentsOf: compiledUrl))
//
//                }
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let model):
//                        self.mlModel = model
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//            } catch {
//                print(error)
//            }
//            DispatchQueue.main.async {
//                self.selectedDataset = url.lastPathComponent
//                self.isLoading = false
//            }
//        } else {
//            // model is not downloaded, download it
//            URLSession.shared.downloadTask(with: url) { (location, _, _) in
//                guard let location = location else { return }
//                do {
//                    // Move the file to the documents directory
//                    try FileManager.default.moveItem(at: location, to: savedURL)
//                    // Compile the model
//                    let compiledUrl = try MLModel.compileModel(at: savedURL)
//                    self.mlModel = try VNCoreMLModel(for: MLModel(contentsOf: compiledUrl))
//                } catch {
//                    print(error)
//                }
//                DispatchQueue.main.async {
//                    self.selectedDataset = url.lastPathComponent
//                    self.isLoading = false
//                }
//            }.resume()
//        }
//    }
//}
