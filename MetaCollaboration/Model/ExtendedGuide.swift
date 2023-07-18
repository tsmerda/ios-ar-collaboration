//
// ExtendedGuide.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct ExtendedGuide: Identifiable, Codable {

    public enum GuideType: String, Codable { 
        case manual = "manual"
        case tutorial = "tutorial"
        case wizard = "wizard"
        case witch = "witch"
    }
    public var id: String?
    public var name: String
    public var _description: String?
    public var imageUrl: String?
    public var guideType: GuideType
    public var objectSteps: [ObjectStep]?

    public init(_id: String? = nil, name: String, _description: String? = nil, imageUrl: String? = nil, guideType: GuideType, objectSteps: [ObjectStep]? = nil) {
        self.id = _id
        self.name = name
        self._description = _description
        self.imageUrl = imageUrl
        self.guideType = guideType
        self.objectSteps = objectSteps
    }

    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case name
        case _description = "description"
        case imageUrl
        case guideType
        case objectSteps
    }

}
