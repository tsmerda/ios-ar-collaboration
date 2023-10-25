//
//  GuideListViewModel+Guides.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 25.10.2023.
//

import Foundation

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
            print("Error writing guide to file: \(error)")
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
                print("File \(jsonDataFile) deleted successfully.")
            } catch {
                print("Error deleting file \(jsonDataFile): \(error)")
            }
        }
    }
}
