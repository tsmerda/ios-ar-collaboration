//
//  SimpleStep.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import Foundation



public struct SimpleStep: Hashable, Identifiable, Codable {
    
    public var id: String?
    public var order: Decimal?
    public var title: String?
    public var objectName: String?
    public var coordinates: [Coordinates]?

    public init(
        id: String? = nil,
        order: Decimal? = nil,
        title: String? = nil,
        objectName: String? = nil,
        coordinates: [Coordinates]? = nil
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.objectName = objectName
        self.coordinates = coordinates
    }

}


#if DEBUG
// MARK: - Example ObjectStep
extension SimpleStep {
    
    static var example: SimpleStep {
        SimpleStep(
            id: "63ef73307b425e2daf8c9081",
            order: 1,
            title: "tiskova hlava"
        )
    }
    
    static var exampleArray: [SimpleStep] = [
        SimpleStep(
            id: "63ef73307b425e2daf8c9081",
            order: 1,
            title: "tiskova hlava"
        ),
        SimpleStep(
            id: "63ef73307b425e2daf8c9082",
            order: 2,
            title: "tiskova hlava 2"
        )
    ]
    
}
#endif
