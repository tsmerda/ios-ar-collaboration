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
    public var name: String?
    public var description: String?
    public var imageUrl: String?
    public var guideType: GuideType
    public var objectSteps: [SimpleStep]?

}

#if DEBUG
// MARK: - Example Guide
extension ExtendedGuideResponse {
    
    static var example: ExtendedGuideResponse {
        ExtendedGuideResponse(name: "Upgrading old Prusa MK2s.",
              description: "How to upgrade the old MK2s to MK2s+ featuring the cool magnetic heatbed.",
              imageUrl: "https://c-3d.niceshops.com/upload/image/product/large/default/bondtech-prusa-i3-mk2-mk2s-extruder-upgrade-1-ks-252884-cs.jpg",
              guideType: .manual
        )
    }
    
}
#endif
