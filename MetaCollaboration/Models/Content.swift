//
// Content.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Content: Codable {

    public enum ContentType: String, Codable { 
        case image = "image"
        case textblock = "textblock"
    }
    public var contentType: ContentType
    public var order: Decimal?
    public var text: String?

    public init(contentType: ContentType, order: Decimal? = nil, text: String? = nil) {
        self.contentType = contentType
        self.order = order
        self.text = text
    }


}
