//
// Step.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Step: Codable {

    public var contents: [Content]
    public var confirmation: Confirmation?
    public var order: Decimal?

    public init(contents: [Content], confirmation: Confirmation? = nil, order: Decimal? = nil) {
        self.contents = contents
        self.confirmation = confirmation
        self.order = order
    }


}
