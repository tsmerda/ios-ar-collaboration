//
//  GuideListViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.10.2023.
//

import Foundation

final class GuideListViewModel: ObservableObject {
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    @Published var guideList: [Guide]?
    @Published var downloadedGuides: [ExtendedGuideResponse] = []
        
    init() {}
    
    // MARK: - Public methods
    
    func isGuideIdDownloaded(_ id: String?) -> Bool {
        if let itemId = id {
            return self.downloadedGuides.contains { item in
                item.id == itemId
            }
        }
        return false
    }
    
    // Remove guides and all downloaded models from device
    func removeAllFromLocalStorage() {
        progressHudState = .shouldShowProgress
        removeAssetsFromDevice()
        downloadedGuides.removeAll()
        PersistenceManager.shared.deleteGuidesJSON()
        progressHudState = .shouldShowSuccess()
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
}

// MARK: - FileManager: Handling guides and assets

extension GuideListViewModel {
    // TODO: error hodit do alert modalu
    func removeAssetsFromDevice() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "arobject" {
                    try FileManager.default.removeItem(at: fileURL)
                    debugPrint("MODEL \(fileURL) REMOVED")
                }
            }
        } catch { debugPrint(error) }
    }
}
