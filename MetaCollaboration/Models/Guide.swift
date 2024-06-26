//
// Guide.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct Guide: Hashable, Identifiable, Codable {
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

    public init(
        id: String? = nil,
        name: String,
        description: String? = nil,
        imageUrl: String? = nil,
        modelName: ModelName? = nil,
        guideType: GuideType
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.modelName = modelName
        self.guideType = guideType
    }
}

#if DEBUG
// MARK: - Example Guide
extension Guide {
    static var example: Guide {
        Guide(name: "Výměna filamentu Prusa i3 MK2.5s",
              description: "Tento průvodce poskytuje jednoduché a přesné instrukce pro výměnu filamentu na 3D tiskárně Prusa i3 MK2.5s. Naučíte se, jak bezpečně a efektivně odstranit starý filament a nainstalovat nový, abyste zajistili optimální kvalitu tisku. Dodržujte kroky v tomto manuálu pro správné a bezproblémové provedení výměny filamentu.",
              imageUrl: "https://c-3d.niceshops.com/upload/image/product/large/default/bondtech-prusa-i3-mk2-mk2s-extruder-upgrade-1-ks-252884-cs.jpg",
              guideType: .manual
        )
    }
}
#endif
