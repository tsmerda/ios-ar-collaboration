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
    func getStepById(guideId: String, objectStepOrder: Decimal) async throws -> ObjectStep
    func getAllAssets() async throws -> [Asset]
    func getAssetByName(assetName: String) async throws -> (URL, String)
    func putObjectStepConfirmation(confirmation: Confirmation, guideId: String, objectStepId: String) async throws
    func putStepConfirmation(confirmation: Confirmation, guideId: String, objectStepId: String, stepId: String) async throws
}

// TODO: -- For the local server, get the IP from the device instead of changing it every time
class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    private let baseURL = "http://192.168.1.14:8080/api/v3"
    
    // MARK: - Get all guides
    func getAllGuides() async throws -> [Guide] {
        guard let url  = URL(string: baseURL + "/guides") else {
            throw NetworkError.invalidURL
        }
        
        // Wait for network access permission
        let config = URLSession.shared.configuration
        config.waitsForConnectivity = true
        
        let (data, response) = try await URLSession(configuration: config).data(from: url)
        
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
    func getStepById(guideId: String, objectStepOrder: Decimal) async throws -> ObjectStep {
        guard let url = URL(string: baseURL + "/guides/\(guideId)/\(objectStepOrder)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
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
    func getAssetByName(assetName: String) async throws -> (URL, String) {
        guard let url = URL(string: baseURL + "/assets/\(assetName)/download") else {
            throw NetworkError.invalidURL
        }
        let (localURL, response) = try await URLSession.shared.download(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        return (localURL, response.suggestedFilename ?? "no-assetname")
    }
    
    // MARK: - Update confirmation for object step by object step id
    func putObjectStepConfirmation(confirmation: Confirmation, guideId: String, objectStepId: String) async throws {
        guard let url = URL(string: baseURL + "/guides/\(guideId)/\(objectStepId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoded = try JSONEncoder().encode(confirmation)
        let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidData
        }
        
        if httpResponse.statusCode != 200 {
            if let errorDetail = try? JSONDecoder().decode(ServerErrorDetail.self, from: data) {
                throw NetworkError.serverResponseError(errorDetail.detail ?? NetworkError.serverError.localizedDescription)
            } else {
                throw NetworkError.unknown(NetworkError.serverError)
            }
        }
    }
    
    // MARK: - Update confirmation for object step by step id
    func putStepConfirmation(confirmation: Confirmation, guideId: String, objectStepId: String, stepId: String) async throws {
        guard let url = URL(string: baseURL + "/guides/\(guideId)/\(objectStepId)/\(stepId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoded = try JSONEncoder().encode(confirmation)
        let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidData
        }
        
        if httpResponse.statusCode != 200 {
            if let errorDetail = try? JSONDecoder().decode(ServerErrorDetail.self, from: data) {
                throw NetworkError.serverResponseError(errorDetail.detail ?? NetworkError.serverError.localizedDescription)
            } else {
                throw NetworkError.unknown(NetworkError.serverError)
            }
        }
    }
}
