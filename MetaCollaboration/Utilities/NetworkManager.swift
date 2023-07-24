//
//  NetworkManager.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.07.2023.
//

import Foundation

protocol NetworkManagerProtocol {
    func getAllGuides() async throws -> [Guide]
    func getGuideById(guideId: String) async throws -> ExtendedGuide
    func getAllAssets() async throws -> [Asset]
    func getAssetByName(assetName: String) async throws -> String
}

class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    private let baseURL = "http://192.168.0.99:8080/api/v3"
    
    // MARK: - Get all guides
    func getAllGuides() async throws -> [Guide] {
        let url = URL(string: baseURL + "/guides")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidStatusCode
        }
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Guide].self, from: data)
    }
    
    // MARK: - Get guide by id
    func getGuideById(guideId: String) async throws -> ExtendedGuide {
        let url = URL(string: baseURL + "/guides/" + guideId)!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidStatusCode
        }
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ExtendedGuide.self, from: data)
    }
    
    // MARK: - Get all assets
    func getAllAssets() async throws -> [Asset] {
        let url = URL(string: baseURL + "/assets")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidStatusCode
        }
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Asset].self, from: data)
    }
    
    // MARK: - Get asset by name
    func getAssetByName(assetName: String) async throws -> String {
        let url = URL(string: baseURL + "/assets/" + assetName + "/download")!
        let (localURL, response) = try await URLSession.shared.download(from: url)
    
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidStatusCode
        }
    
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "no-assetname")
    
        // Check if file is already downloaded
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // print("Asset already downloaded \(fileURL.lastPathComponent)")
            return fileURL.lastPathComponent
        }
    
        try FileManager.default.moveItem(at: localURL, to: fileURL)
        return response.suggestedFilename ?? "no-assetname"
    
    }
}
