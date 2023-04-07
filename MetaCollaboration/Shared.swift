//
//  Shared.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 23.02.2023.
//

import Foundation

class Shared {
    static let shared = Shared()
    
    var baseUrl: URL {
        guard let url = URL(string: "http://192.168.1.6:8080/api/v3") else { fatalError("No base URL") }
        return url
    }
}
