//
//  NetworkManager.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.07.2023.
//

import Foundation

protocol NetworkManagerProtocol {
    func getAllGuides(completion: @escaping (Result<[Guide], NetworkError>) -> Void)
    func getGuideById(guideId: String, completion: @escaping (Result<ExtendedGuide, NetworkError>) -> Void)
    func getAllAssets(completion: @escaping (Result<[Asset], NetworkError>) -> Void)
    func getAssetByName(assetName: String, loadingCallback: @escaping (Bool) -> Void, completion: @escaping (Result<String, NetworkError>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    private let baseURL = "http://192.168.0.125:8080/api/v3"
    
    // MARK: - Get all guides
    func getAllGuides(completion: @escaping (Result<[Guide], NetworkError>) -> Void) {
        guard let url = URL(string: baseURL + "/guides") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.waitsForConnectivity = true
        
        let task = URLSession(configuration: sessionConfig).dataTask(with: URLRequest(url: url)) { data, response, error in
            if let _ =  error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode([Guide].self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    // MARK: - Get guide by id
    func getGuideById(guideId: String, completion: @escaping (Result<ExtendedGuide, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL + "/guides/" + guideId) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let _ =  error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(ExtendedGuide.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    // MARK: - Get all assets
    func getAllAssets(completion: @escaping (Result<[Asset], NetworkError>) -> Void) {
        guard let url = URL(string: baseURL + "/assets") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let _ =  error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode([Asset].self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    // MARK: - Get asset by name
    func getAssetByName(assetName: String, loadingCallback: @escaping (Bool) -> Void, completion: @escaping (Result<String, NetworkError>) -> Void) {
        loadingCallback(true)
        
        guard let url = URL(string: baseURL + "/assets/" + assetName + "/download") else {
            loadingCallback(false)
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let _ =  error {
                loadingCallback(false)
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                loadingCallback(false)
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let localURL = localURL else {
                loadingCallback(false)
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "no-assetname")
                
                // Check if file is already downloaded
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    // print("Asset already downloaded \(fileURL.lastPathComponent)")
                    completion(.success(fileURL.lastPathComponent))
                    return
                }
                
                try FileManager.default.moveItem(at: localURL, to: fileURL)
                loadingCallback(false)
                completion(.success(response.suggestedFilename ?? "no-assetname"))
                
            } catch {
                loadingCallback(false)
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
}
