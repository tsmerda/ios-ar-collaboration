//
//  NetworkManager.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.07.2023.
//

import Foundation

protocol NetworkManagerProtocol {
    func getAllGuides() async throws -> [Guide]
    func getGuideById(guideId: String) async throws -> ExtendedGuideResponse
    func getStepById(guideId: String, objectStepOrder: Int) async throws -> ObjectStep
    func getAllAssets() async throws -> [Asset]
    func getAssetByName(assetName: String) async throws -> String
    func putGuideConfirmation(guide: Guide) async throws
}

class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    private let baseURL = "http://192.168.10.138:8080/api/v3"
    
    // MARK: - Get all guides
    func getAllGuides() async throws -> [Guide] {
        guard let url  = URL(string: baseURL + "/guides") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        print(String(decoding: data, as: UTF8.self))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let guides = try? decoder.decode([Guide].self, from: data) else {
            throw NetworkError.invalidData
        }
        
        return guides
    }
    
    // MARK: - Get guide by id
    func getGuideById(guideId: String) async throws -> ExtendedGuideResponse {
        guard let url = URL(string: baseURL + "/guides/\(guideId)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        print(String(decoding: data, as: UTF8.self))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let guide = try? decoder.decode(ExtendedGuideResponse.self, from: data) else {
            throw NetworkError.invalidData
        }
        
        return guide
    }
    
    // MARK: - Get object step by id and step order
    func getStepById(guideId: String, objectStepOrder: Int) async throws -> ObjectStep {
        guard let url = URL(string: baseURL + "/guides/\(guideId)/\(objectStepOrder)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        print(String(decoding: data, as: UTF8.self))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let step = try? decoder.decode(ObjectStep.self, from: data) else {
            throw NetworkError.invalidData
        }
        
        return step
    }
    
    // MARK: - Get all assets
    func getAllAssets() async throws -> [Asset] {
        guard let url = URL(string: baseURL + "/assets") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        print(String(decoding: data, as: UTF8.self))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let asset = try? decoder.decode([Asset].self, from: data) else {
            throw NetworkError.invalidData
        }
        
        return asset
    }
    
    // MARK: - Get asset by name
    func getAssetByName(assetName: String) async throws -> String {
        guard let url = URL(string: baseURL + "/assets/\(assetName)/download") else {
            throw NetworkError.invalidURL
        }
        let (localURL, response) = try await URLSession.shared.download(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "no-assetname")
        
        // Check if file is already downloaded
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL.lastPathComponent
        }
        
        try FileManager.default.moveItem(at: localURL, to: fileURL)
        return response.suggestedFilename ?? "no-assetname"
    }
    
    // MARK: - Put guide confirmation by guide
    func putGuideConfirmation(guide: Guide) async throws {
        guard let url = URL(string: baseURL + "/guides/\(guide.id!)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoded = try JSONEncoder().encode(guide)
        let (_, response) = try await URLSession.shared.upload(for: request, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.serverError
        }
    }
}
