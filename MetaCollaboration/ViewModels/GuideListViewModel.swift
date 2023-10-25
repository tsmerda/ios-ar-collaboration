//
//  GuideListViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.10.2023.
//

import Foundation
import ARKit

final class GuideListViewModel: ObservableObject {
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    
    @Published var currentGuide: ExtendedGuideResponse? /*= ExtendedGuideResponse.example*/
    @Published var guideList: [Guide]?
    @Published var referenceObjects = Set<ARReferenceObject>() {
        didSet {
            debugPrint("NEW reference Object")
            debugPrint(referenceObjects)
        }
    }
    @Published var downloadedGuides: [ExtendedGuideResponse] = []
    //    TODO: -- SAVE TO DEVICE LOCALY
    //    {
    //        didSet {
    //            // Save downloadedGuides locally to JSON or delete JSON
    //            if !downloadedGuides.isEmpty {
    //                saveGuidesToJSON(downloadedGuides)
    //            } else {
    //                deleteGuidesJSON()
    //            }
    //        }
    //    }
    @Published var downloadedAssets: [String] = []
//    {
//        didSet {
//            if !downloadedAssets.isEmpty {
//                if let lastAddedElement = downloadedAssets.last {
//                    loadReferenceObjects(lastAddedElement)
//                }
//            } else {
//                removeAssetsFromDevice()
//            }
//        }
//    }
    
    let jsonDataFile = "guidesData.json"
    
    init() {
        // Check downloaded guide saved in UserDefaults and add into currentGuide
        //        downloadedGuides = readGuidesFromJSON()
        // Check downloaded assets saved in device local storage and add into downloadedAssets
        //        initDownloadedAssets()
    }
    
    // MARK: - Public methods
    
    func downloadedGuideById(_ id: String?) -> ExtendedGuideResponse? {
        if let guide = self.downloadedGuides.first(where: { $0.id == id }) {
            return guide
        }
        return nil
    }
    
    func isGuideIdDownloaded(_ id: String?) -> Bool {
        if let itemId = id {
            return self.downloadedGuides.contains { item in
                item.id == itemId
            }
        }
        return false
    }
    
    func setCurrentGuide(_ id: String) {
        if let guide = self.downloadedGuides.first(where: { $0.id == id }) {
            self.currentGuide = guide
        }
    }
    
    // Remove guide and all downloaded models from device
    func removeAllFromLocalStorage() {
        //    TODO: ARObject zustava inicializovany => resetovat AR session nebo colaboration view
        currentGuide = nil
        referenceObjects.removeAll()
        downloadedAssets.removeAll()
        downloadedGuides.removeAll()
    }
}

// MARK: - Network methods

extension GuideListViewModel {
    
    // ========
    // In offline mode, client download all the ML and USDZ models within guides to be able to use an AR and collaborative experience
    // In online mode, is not necessary to download all assets at once instead there is ongoing communication with the backend all the time.
    // ========
    
    // Get list of all guides
    func getAllGuides() {
        Task { @MainActor in
            progressHudState = .shouldShowProgress
            do {
                guideList = try await NetworkManager.shared.getAllGuides()
                progressHudState = .shouldHideProgress
            } catch {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
    
    // Get guide by ID
    func getGuideById(id: String) {
        Task { @MainActor in
            progressHudState = .shouldShowProgress
            do {
                let guide = try await NetworkManager.shared.getGuideById(guideId: id)
                downloadedGuides.append(guide)
                
                // TODO: - Implementovat stazeni vsech modelu, ktere jsou v danym <guide>
                getAssetByName(assetName: "camel")
                
                // Download all assets related to guide steps
                //                if let objectSteps = value.objectSteps {
                //                    for objectStep in objectSteps {
                //                        if let objectName = objectStep.objectName {
                //                            // Download models based on objectName from guideStep
                //                            self.getAssetByName(assetName: objectName)
                //                        }
                //                    }
                //                }
                progressHudState = .shouldHideProgress
            } catch {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
    
    // Download asset by name
    func getAssetByName(assetName: String) {
        Task { @MainActor in
            progressHudState = .shouldShowProgress
            do {
                let downloadedAsset = try await NetworkManager.shared.getAssetByName(assetName: assetName)
                if !downloadedAssets.contains(downloadedAsset) {
                    downloadedAssets.append(downloadedAsset)
                    loadReferenceObjects(downloadedAsset)
                }
                progressHudState = .shouldHideProgress
            } catch {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
}
