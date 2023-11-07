//
//  ExtendedGuideResponse.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import Foundation

public struct ExtendedGuideResponse: Hashable, Identifiable, Codable {
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
    public var modelName: ModelName?
    public var guideType: GuideType
    public var objectSteps: [SimpleStep]?

    public init(
        id: String? = nil,
        name: String,
        description: String? = nil,
        imageUrl: String? = nil,
        modelName: ModelName? = nil,
        guideType: GuideType,
        objectSteps: [SimpleStep]? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.modelName = modelName
        self.guideType = guideType
        self.objectSteps = objectSteps
    }
}

#if DEBUG
// MARK: - Example Guide
extension ExtendedGuideResponse {
    
    static var example: ExtendedGuideResponse {
        ExtendedGuideResponse(
            name: "Upgrading old Prusa MK2s.",
            description: "How to upgrade the old MK2s to MK2s+ featuring the cool magnetic heatbed.",
            imageUrl: "https://c-3d.niceshops.com/upload/image/product/large/default/bondtech-prusa-i3-mk2-mk2s-extruder-upgrade-1-ks-252884-cs.jpg",
            guideType: .manual
        )
    }
    
}
#endif
