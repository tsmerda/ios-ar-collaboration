//
//  CollaborationViewModel+Assets.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 07.08.2023.
//

import Foundation
import ARKit

extension CollaborationViewModel {
    
    func loadReferenceObjects(_ assetName: String) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for fileURL in fileURLs {
                //            TODO: - Resolve: failed to setup referenceObjects nilError
                if fileURL.pathExtension == "arobject" && fileURL.lastPathComponent == assetName {
                    let referenceObject = try ARReferenceObject(archiveURL: fileURL)
                    referenceObjects.insert(referenceObject)
                }
            }
        } catch {
            // TODO: hodit do alert modalu
            print("Failed to set up referenceObjects: \(error)")
        }
    }
    
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
            print(error)
        }
    }
    
    // TODO: hodit do alert modalu
    func removeAssetsFromDevice() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "arobject" {
                    try FileManager.default.removeItem(at: fileURL)
                    print("Model \(fileURL) removed")
                }
            }
        } catch { print(error) }
    }
    
}
