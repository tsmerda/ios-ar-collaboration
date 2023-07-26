//
//  GuideRowView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 25.07.2023.
//

import SwiftUI

struct GuideRowView: View {
    let guide: Guide
    var isDownloaded: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(guide.name)")
                    .font(.system(size: 17).bold())
                    .foregroundColor(.white)
                
                Text("\(guide.description ?? "")")
                    .font(.subheadline)
                    .foregroundColor(Color("disabledColor"))
                    .multilineTextAlignment(.leading)
            }
            
            if isDownloaded {
                Image(systemName: "play")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
        }
        .padding(2)
        .cornerRadius(8)
    }
}

struct GuideRowView_Previews: PreviewProvider {
    static var previews: some View {
        GuideRowView(guide: Guide(name: "Guide", guideType: .manual), isDownloaded: false)
    }
}
