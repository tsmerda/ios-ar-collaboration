//
//  SimpleStep.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import Foundation



public struct SimpleStep: Hashable, Identifiable, Codable {

    public var id: String
    public var order: Int?
    public var title: String?
    
    public init(id: String? = nil, title: String? = nil, order: Int? = nil) {
        self.id = id ?? UUID().uuidString
        self.order = order
        self.title = title
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        order = try container.decodeIfPresent(Int.self, forKey: .order)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
    
}


#if DEBUG
// MARK: - Example ObjectStep
extension SimpleStep {
    
    static var example: SimpleStep {
        SimpleStep(id: "63ef73307b425e2daf8c9081", title: "tiskova hlava", order: 1)
    }
    
    static var exampleArray: [SimpleStep] = [
        SimpleStep(id: "63ef73307b425e2daf8c9081", title: "tiskova hlava", order: 1),
        SimpleStep(id: "63ef73307b425e2daf8c9082", title: "tiskova hlava 2", order: 2)
    ]
    
}
#endif
