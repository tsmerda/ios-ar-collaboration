//
//  SimpleStep.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import Foundation



public struct SimpleStep: Codable {

    public var order: Decimal?
    public var title: String?

    public init(order: Decimal? = nil, title: String? = nil) {
        self.order = order
        self.title = title
    }


}
