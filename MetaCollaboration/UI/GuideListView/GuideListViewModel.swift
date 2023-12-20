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
    
    init() {
        getAllGuides()
    }
    
    // MARK: - Public methods
    
    func isGuideIdDownloaded(_ id: String?) -> Bool {
        guard let itemId = id else { return false }
        return self.downloadedGuides.contains { item in
            item.id == itemId
        }
    }
    
    // Remove guides and all downloaded models from device
    func removeAllFromLocalStorage() {
        Task { @MainActor in
            progressHudState = .shouldShowProgress
            do {
                try removeAssetsFromDevice()
                downloadedGuides.removeAll()
                try PersistenceManager.shared.deleteGuidesJSON()
                self.progressHudState = .shouldShowSuccess(message: L.GuideList.allAssetsSaved)
            } catch {
                self.progressHudState = .shouldShowFail(message: "\(L.GuideList.failedToDelete)\(error.localizedDescription)")
            }
        }
    }
    
    func isGuideCompleted(_ id: String?) -> Bool {
        guard let itemId = id else { return false }
        if let guide = downloadedGuides.first(where: { $0.id == itemId }),
           let objectSteps = guide.objectSteps {
            return objectSteps.allSatisfy { $0.confirmation?.done ?? false }
        }
        return false
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
    func removeAssetsFromDevice() throws {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: documentsUrl,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        for fileURL in fileURLs {
            try FileManager.default.removeItem(at: fileURL)
            debugPrint("\(fileURL.lastPathComponent): DELETED")
        }
    }
}
