//
//  NetworkError.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.07.2023.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case serverError
    case invalidData
    case unkown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return ""
        case .serverError:
            return "There was an error with the server. Please try again later"
        case .invalidData:
            return "The server data is invalid. Please try again later"
        case .unkown(let error):
            return error.localizedDescription
        }
    }
}
