//
//  GuideRowView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 25.07.2023.
//

import SwiftUI

struct GuideRowView: View {
    private let guide: Guide
    private var isDownloaded: Bool
    private let isCompleted: Bool
    
    init(
        guide: Guide,
        isDownloaded: Bool,
        isCompleted: Bool
    ) {
        self.guide = guide
        self.isDownloaded = isDownloaded
        self.isCompleted = isCompleted
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("\(guide.name)")
                        .font(.system(size: 17).bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Text("\(guide.description ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color("disabledColor"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                }
                Spacer()
                VStack {
                    if isDownloaded {
                        Image(systemName: "play")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(20)
            .background(Color("secondaryColor"))
            .cornerRadius(8)
            
            if isCompleted {
                Text("Completed")
                    .font(.system(size: 10).weight(.bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 3)
                    .background(Color.accentColor)
                    .cornerRadius(6)
                    .padding([.top, .trailing], 10)
            }
        }
    }
}

struct GuideRowView_Previews: PreviewProvider {
    static var previews: some View {
        GuideRowView(
            guide: Guide.example,
            isDownloaded: false,
            isCompleted: true
        )
    }
}
