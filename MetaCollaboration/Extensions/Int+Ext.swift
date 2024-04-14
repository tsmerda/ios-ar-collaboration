//
//  Int+Ext.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 14.04.2024.
//

import Foundation

extension Int {
    var ratingDescription: String {
        switch self {
        case 1:
            return L.Stars.one
        case 2...4:
            return L.Stars.twoToFour
        default:
            return L.Stars.fourAndMore
        }
    }
}
