//
//  SettingsLabelView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import SwiftUI

struct SettingsLabelView: View {
    
    var labelText: String
    var labelImage: String
    
    var body: some View {
        HStack {
            Text(labelText)
                .fontWeight(.bold)
            Spacer()
            Image(systemName: labelImage)
                .fontWeight(.regular)
        }
    }
}

struct SettingsLabelView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLabelView(labelText: "Info", labelImage: "info.circle")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
