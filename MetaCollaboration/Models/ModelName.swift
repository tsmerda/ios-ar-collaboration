//
//  ModelName.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.10.2023.
//

import Foundation



public struct ModelName: Codable {

    public var ios: String?
    public var android: String?

    public init(ios: String? = nil, android: String? = nil) {
        self.ios = ios
        self.android = android
    }


}
