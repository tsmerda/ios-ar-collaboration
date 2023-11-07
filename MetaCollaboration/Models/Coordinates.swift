//
//  Coordinates.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.10.2023.
//

import Foundation

public struct Coordinates: Hashable, Codable {
    public var x: Int?
    public var y: Int?
    public var z: Int?

    public init(
        x: Int? = nil,
        y: Int? = nil,
        z: Int? = nil
    ) {
        self.x = x
        self.y = y
        self.z = z
    }
}
