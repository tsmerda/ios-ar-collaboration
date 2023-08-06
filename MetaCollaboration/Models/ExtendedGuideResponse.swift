//
//  ExtendedGuideResponse.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import Foundation



public struct ExtendedGuideResponse: Codable {

    public enum GuideType: String, Codable {
        case manual = "manual"
        case tutorial = "tutorial"
        case wizard = "wizard"
        case witch = "witch"
    }
    public var id: String?
    public var name: String
    public var description: String?
    public var imageUrl: String?
    public var guideType: GuideType
    public var objectSteps: [SimpleStep]?

    public init(id: String? = nil, name: String, description: String? = nil, imageUrl: String? = nil, guideType: GuideType, objectSteps: [SimpleStep]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.guideType = guideType
        self.objectSteps = objectSteps
    }

}
