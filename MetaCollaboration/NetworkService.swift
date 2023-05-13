//
//  NetworkService.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 23.02.2023.
//

import Foundation

protocol NetworkServiceProtocol {
    func getAllGuides(completion: @escaping (Result<[Guide], Error>) -> Void)
    func getGuideById(guideId: String, completion: @escaping (Result<ExtendedGuide, Error>) -> Void)
    func getAllAssets(completion: @escaping (Result<[Asset], Error>) -> Void)
    func getAssetByName(assetName: String, loadingCallback: @escaping (Bool) -> Void, completion: @escaping (Result<String, Error>) -> Void)
    
}

class NetworkService: NetworkServiceProtocol {
    
    func getAllGuides(completion: @escaping (Result<[Guide], Error>) -> Void) {
        let urlString = Shared.shared.baseUrl.absoluteString + "/guides"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if response.statusCode == 200 {
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let guide = try JSONDecoder().decode([Guide].self, from: data)
                            completion(.success(guide))
                        } catch let error {
                            print("Error decoding: ", error)
                            completion(.failure(NetworkError.invalidResponse))
                        }
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            }
        }
        task.resume()
    }
    
    func getGuideById(guideId: String, completion: @escaping (Result<ExtendedGuide, Error>) -> Void) {
        let urlString = Shared.shared.baseUrl.absoluteString + "/guides/" + guideId
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if response.statusCode == 200 {
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let guide = try JSONDecoder().decode(ExtendedGuide.self, from: data)
                            completion(.success(guide))
                        } catch let error {
                            print("Error decoding: ", error)
                            completion(.failure(NetworkError.invalidResponse))
                        }
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            }
        }
        task.resume()
    }
    
    func getAllAssets(completion: @escaping (Result<[Asset], Error>) -> Void) {
        let urlString = Shared.shared.baseUrl.absoluteString + "/assets"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if response.statusCode == 200 {
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let assets = try JSONDecoder().decode([Asset].self, from: data)
                            completion(.success(assets))
                        } catch let error {
                            print("Error decoding: ", error)
                            completion(.failure(NetworkError.invalidResponse))
                        }
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            }
        }
        task.resume()
    }
    
    func getAssetByName(assetName: String, loadingCallback: @escaping (Bool) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        loadingCallback(true)

        let urlString = Shared.shared.baseUrl.absoluteString + "/assets/" + assetName + "/download"
        guard let url = URL(string: urlString) else {
            loadingCallback(false)
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                loadingCallback(false)
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                loadingCallback(false)
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                if let localURL = localURL {
                    do {
                        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        let fileURL = documentsURL.appendingPathComponent(response?.suggestedFilename ?? "no-assetname")
                        
                        // Check if file is already downloaded
                        if FileManager.default.fileExists(atPath: fileURL.path) {
//                            print("Asset already downloaded \(fileURL.lastPathComponent)")
                            completion(.success(fileURL.lastPathComponent))
                            return
                        }
                        
                        try FileManager.default.moveItem(at: localURL, to: fileURL)
                        print("Asset saved to \(fileURL)")
                        loadingCallback(false)
                        completion(.success(fileURL.lastPathComponent))
                    } catch {
                        print("Error saving asset: \(error)")
                        loadingCallback(false)
                        completion(.failure(NetworkError.invalidResponse))
                    }
                }
            default:
                print("Error - \(httpResponse.statusCode)")
                loadingCallback(false)
                completion(.failure(NetworkError.invalidURL))
            }
        }
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
}
