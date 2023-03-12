//
//  NetworkService.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 23.02.2023.
//

import Foundation

protocol NetworkServiceProtocol {
    func getAllGuides(completion: @escaping (Result<[Guide], Error>) -> Void)
    func getGuideById(guideId: String, completion: @escaping (Result<Guide, Error>) -> Void)
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
    
    func getGuideById(guideId: String, completion: @escaping (Result<Guide, Error>) -> Void) {
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
                            let guide = try JSONDecoder().decode(Guide.self, from: data)
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
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
}
