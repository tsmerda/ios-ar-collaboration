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
    @Published var downloadedGuides: [ExtendedGuideResponse] = [] {
        didSet {
            // Save downloadedGuides locally to JSON or delete JSON
            if !downloadedGuides.isEmpty {
                saveGuidesToJSON(downloadedGuides)
            } else {
                deleteGuidesJSON()
            }
        }
    }
    
    let jsonDataFile = "guidesData.json"
    
    init() {
        // Check downloaded guide saved in UserDefaults and add into currentGuide
        downloadedGuides = readGuidesFromJSON()
    }
    
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
    func guidesJSONExists() -> Bool {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(jsonDataFile)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func saveGuidesToJSON(_ guides: [ExtendedGuideResponse]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(guides)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(jsonDataFile)
                try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                // print("Guide successfully written to file: \(fileURL)")
            }
        } catch {
            debugPrint("Error writing guide to file: \(error)")
        }
    }
    
    func readGuidesFromJSON() -> [ExtendedGuideResponse] {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(jsonDataFile)
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([ExtendedGuideResponse].self, from: jsonData)
        } catch {
            return []
        }
    }
    
    func deleteGuidesJSON() {
        if guidesJSONExists() {
            let fileManager = FileManager.default
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(jsonDataFile)
            
            do {
                try fileManager.removeItem(at: fileURL)
                debugPrint("FILE \(jsonDataFile) DELETED SUCCESSFULLY.")
            } catch {
                debugPrint("Error deleting file \(jsonDataFile): \(error)")
            }
        }
    }
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
