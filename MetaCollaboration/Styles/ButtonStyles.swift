//
//  ButtonStyles.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 25.07.2023.
//

import SwiftUI

struct ButtonStyledFill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16).weight(.semibold))
            .foregroundStyle(.black)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(16)
    }
}

struct ButtonStyledOutline: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16).weight(.semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
    }
}
