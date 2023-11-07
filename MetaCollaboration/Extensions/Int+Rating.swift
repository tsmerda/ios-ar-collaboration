//
//  Int+Rating.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 07.11.2023.
//

import Foundation

extension Int {
    var ratingDescription: String {
        switch self {
            case 1:
                return "hvězdička"
            case 2...4:
                return "hvězdičky"
            default:
                return "hvězdiček"
        }
    }
}
