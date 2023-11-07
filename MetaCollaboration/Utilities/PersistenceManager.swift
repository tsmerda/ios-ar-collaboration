//
//  PersistenceManager.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 07.11.2023.
//

import Foundation

// TODO: -- create protocol for this

class PersistenceManager {
    static let shared = PersistenceManager()
    private init() {}
    
    private let jsonDataFile = "guidesData.json"
    
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
    
    func loadGuidesFromJSON() -> [ExtendedGuideResponse] {
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
    
    func updateGuide(_ updatedGuide: ExtendedGuideResponse) {
        // Read current guides from the JSON file
        var currentGuides = loadGuidesFromJSON()
        
        // Find the index of the guide that needs to be updated
        if let index = currentGuides.firstIndex(where: { $0.id == updatedGuide.id }) {
            // Update the guide at the found index
            currentGuides[index] = updatedGuide
            // Write the updated guides array back to the JSON file
            saveGuidesToJSON(currentGuides)
        } else {
            // The guide was not found, handle the error as needed
            debugPrint("Guide to update not found")
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
    
    func guidesJSONExists() -> Bool {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(jsonDataFile)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}
