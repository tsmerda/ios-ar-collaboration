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
    private let onDownloadGuide: (ExtendedGuideResponse) -> Void
    private var downloadedGuides: [ExtendedGuideResponse] = []
    @Published var downloadedAssets: [String] = [] {
        didSet {
            if let lastAddedElement = downloadedAssets.last {
                loadReferenceObjects(lastAddedElement)
            }
        }
    }
    @Published var referenceObjects = Set<ARReferenceObject>()
    var downloadedGuide: Bool {
        if let itemId = guide.id {
            return self.downloadedGuides.contains { item in
                item.id == itemId
            }
        }
        return false
    }
    
    init(
        guide: Guide,
        downloadedGuides: [ExtendedGuideResponse],
        onDownloadGuide: @escaping (ExtendedGuideResponse) -> Void
    ) {
        self.guide = guide
        self.downloadedGuides = downloadedGuides
        self.onDownloadGuide = onDownloadGuide
        // Check downloaded assets saved in device local storage and add into downloadedAssets
        initDownloadedAssets()
    }
    
    func onSetCurrentGuideAction(_ id: String) {
        if let guide = self.downloadedGuides.first(where: { $0.id == id }) {
            self.currentGuide = guide
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
                // TODO: pridat do GuideListViewModel
                downloadedGuides.append(guide)
                onDownloadGuide(guide)
                
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
                    // loadReferenceObjects(downloadedAsset)
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
    func loadReferenceObjects(_ assetName: String) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for fileURL in fileURLs {
                // TODO: - Resolve: failed to setup referenceObjects nilError
                if fileURL.pathExtension == "arobject" && fileURL.lastPathComponent == assetName {
                    let referenceObject = try ARReferenceObject(archiveURL: fileURL)
                    referenceObjects.insert(referenceObject)
                }
            }
        } catch {
            // TODO: hodit do alert modalu
            debugPrint("Failed to set up referenceObjects: \(error)")
        }
    }
    
    // TODO: error hodit do alert modalu
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
            debugPrint(error)
        }
    }
}
