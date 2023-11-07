//
//  View+Keyboard.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 07.11.2023.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
