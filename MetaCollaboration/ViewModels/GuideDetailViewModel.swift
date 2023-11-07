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
        initReferenceObjects()
    }
    
    func onSetCurrentGuideAction(_ id: String) {
        if let guide = self.downloadedGuides.first(where: { $0.id == id }) {
            self.currentGuide = guide
        }
    }
    
    func insertReferenceObject(_ referenceObjectURL: URL) async throws {
        // TODO: -- porovnat zda jiz existuje v Setu referenceObjects
        do {
            // Check whether the file exists
            if FileManager.default.fileExists(atPath: referenceObjectURL.path) {
                let referenceObject = try ARReferenceObject(archiveURL: referenceObjectURL)
                self.referenceObjects.insert(referenceObject)
            } else {
                debugPrint("File does not exist at \(referenceObjectURL.path)")
            }
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
                PersistenceManager.shared.saveGuidesToJSON(downloadedGuides)
                
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
                let (assetUrl, responseAssetName) = try await NetworkManager.shared.getAssetByName(assetName: assetName)
                if let savedReferenceObjectURL = try await saveReferenceObjects(assetUrl, responseAssetName) {
                    try await insertReferenceObject(savedReferenceObjectURL)
                } else {
                    debugPrint("Failed to save referenceObject locally")
                }
                progressHudState = .shouldHideProgress
            } catch {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - FileManager: handling assets and reference objects

extension GuideDetailViewModel {
    func saveReferenceObjects(_ assetUrl: URL, _ assetName: String) async throws -> URL? {
        guard (assetUrl as NSURL).checkResourceIsReachableAndReturnError(nil) else {
            // File is not reachable, deal with error and return
            progressHudState = .shouldShowFail(message: "File is not reachable")
            return nil
        }
        
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentsURL.appendingPathComponent(assetName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            debugPrint("Reference object is already downloaded")
            return fileURL
        }
        
        try FileManager.default.moveItem(at: assetUrl, to: fileURL)
        return fileURL
    }
    
    // TODO: error hodit do alert modalu
    func initReferenceObjects() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for fileURL in fileURLs {
                // TODO: - Resolve: failed to setup referenceObjects nilError
                if fileURL.pathExtension == "arobject" {
                    let referenceObject = try ARReferenceObject(archiveURL: fileURL)
                    self.referenceObjects.insert(referenceObject)
                }
            }
        } catch {
            // TODO: hodit do alert modalu
            debugPrint("Failed to set up referenceObjects: \(error)")
        }
    }
}
