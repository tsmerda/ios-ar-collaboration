//
//  NetworkError.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.07.2023.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case serverError
    case invalidData
    case serverResponseError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L.Error.invalidURL
        case .serverError:
            return L.Error.serverError
        case .invalidData:
            return L.Error.invalidData
        case .serverResponseError(let detail):
            return detail
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

struct ServerErrorDetail: Decodable {
    let detail: String?
    let status: Int?
    let title: String?
    let type: String?
}
