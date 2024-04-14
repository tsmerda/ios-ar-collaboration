//
//  GuideDetailViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.10.2023.
//

import Foundation
import ARKit

final class GuideDetailViewModel: ObservableObject {
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    @Published var guide: Guide
    @Published var currentGuide: ExtendedGuideResponse?
    @Published var downloadedGuides: [ExtendedGuideResponse] = []
    // referenceObjects DOESNT NOT WORK ON SIMULATOR!
    @Published var referenceObjects: Set<ARReferenceObject> = []
    @Published var usdzModels: Set<URL> = []
    var downloadedGuide: Bool {
        guard let itemId = guide.id else { return false }
        return self.downloadedGuides.contains { item in
            item.id == itemId
        }
    }
    var isGuideCompleted: Bool {
        guard let itemId = guide.id else { return false }
        if let guide = downloadedGuides.first(where: { $0.id == itemId }),
           let objectSteps = guide.objectSteps {
            return objectSteps.allSatisfy { $0.confirmation?.done ?? false }
        }
        return false
    }
    
    init(guide: Guide) {
        self.guide = guide
        // Check downloaded reference objects saved locally and insert into referenceObjects
        // TODO: -- init just reference objects that are for current guide
        initAssets()
    }
    
    func onSetCurrentGuideAction(_ id: String) {
        if let guide = self.downloadedGuides.first(where: { $0.id == id }) {
            self.currentGuide = guide
        } else {
            self.currentGuide = nil
        }
    }
    
    func insertReferenceObject(_ referenceObjectURL: URL) async throws {
        do {
            let referenceObject = try ARReferenceObject(archiveURL: referenceObjectURL)
            self.referenceObjects.insert(referenceObject)
        } catch {
            debugPrint("Error loading reference object from \(referenceObjectURL.absoluteString): \(error)")
        }
    }
}

// MARK: - Network methods

extension GuideDetailViewModel {
    // Get guide by ID
    func getGuideById(_ id: String) {
        Task { @MainActor in
            progressHudState = .shouldShowProgress
            do {
                let guide = try await NetworkManager.shared.getGuideById(guideId: id)
                downloadedGuides.append(guide)
                try PersistenceManager.shared.saveGuidesToJSON(downloadedGuides)
                
                guard let referenceobjectName = guide.modelName?.ios else {
                    throw NSError(domain: "GuideDetailViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get guide reference model name for iOS."])
                }
                var assetDownloadTasks = [Task<(), Error>]()
                assetDownloadTasks.append(Task { try await getAssetByName(assetName: referenceobjectName) })
                
                if let objectSteps = guide.objectSteps {
                    for objectStep in objectSteps {
                        if let objectName = objectStep.objectName {
                            assetDownloadTasks.append(Task { try await getAssetByName(assetName: objectName) })
                        }
                    }
                }
                
                for task in assetDownloadTasks {
                    try await task.value
                }
                progressHudState = .shouldHideProgress
            } catch {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
    
    // Download asset by name
    func getAssetByName(assetName: String) async throws {
        let (assetUrl, responseAssetName) = try await NetworkManager.shared.getAssetByName(assetName: assetName)
        let assetExtension = URL(fileURLWithPath: responseAssetName).pathExtension
        
        if assetExtension == "arobject" {
            if let savedReferenceObjectURL = try await saveAssetLocally(assetUrl, responseAssetName) {
                try await insertReferenceObject(savedReferenceObjectURL)
                // debugPrint(savedReferenceObjectURL)
            } else {
                // TODO: - make class for this error
                throw NSError(domain: "GuideDetailViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to save ARObject locally."])
            }
        } else if assetExtension == "usdz" {
            if let savedUSDZURL = try await saveAssetLocally(assetUrl, responseAssetName) {
                self.usdzModels.insert(savedUSDZURL)
                // debugPrint(savedUSDZURL)
            } else {
                throw NSError(domain: "GuideDetailViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to save USDZ model locally."])
            }
        }
    }
}

// MARK: - FileManager: handling assets and reference objects

extension GuideDetailViewModel {
    func saveAssetLocally(_ assetUrl: URL, _ assetName: String) async throws -> URL? {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentsURL.appendingPathComponent(assetName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            debugPrint("\(assetName) is already downloaded")
            return fileURL
        }
        try FileManager.default.moveItem(at: assetUrl, to: fileURL)
        return fileURL
    }
    
    // TODO: error hodit do alert modalu
    func initAssets() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                // TODO: - Resolve: failed to setup referenceObjects nilError
                if fileURL.pathExtension == "arobject" {
                    let referenceObject = try ARReferenceObject(archiveURL: fileURL)
                    self.referenceObjects.insert(referenceObject)
                } else if fileURL.pathExtension == "usdz" {
                    self.usdzModels.insert(fileURL)
                }
            }
        } catch {
            // TODO: hodit do alert modalu
            debugPrint("Failed to set up referenceObjects: \(error)")
        }
    }
}
