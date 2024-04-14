//
//  View+Ext.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 14.04.2024.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
