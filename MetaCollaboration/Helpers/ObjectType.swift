//
//  ObjectType.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 07.11.2023.
//

import Foundation
import RealityKit

struct ObjectType: Component {
    enum ObjectKind {
        case detected
        case inserted
    }
    
    let kind: ObjectKind
}
