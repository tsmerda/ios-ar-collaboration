//
//  GuideDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct GuideDetailView: View {
    
    var guide: Guide?
    var downloadedGuide: ExtendedGuideResponse?
    
    let onGetGuideAction: () -> Void
    let onSetCurrentGuideAction: () -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        Text(guide?.name ?? "Guide name")
                            .font(.system(size: 24).bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(guide?.guideType.rawValue.capitalized ?? "")
                            .font(.system(size: 17))
                            .foregroundColor(.accentColor)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 16)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .padding(.bottom)
                    
                    Text(guide?.description ?? "Guide description")
                        .font(.subheadline)
                        .foregroundColor(Color("disabledColor"))
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 24)
                    
                    if guide?.imageUrl != nil {
                        AsyncImage(url: URL(string: (guide?.imageUrl)!)){ image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(8)
                        } placeholder: { Color("secondaryColor") }
                            .frame(width: .infinity, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.bottom, 16)
                    }
                    
//                    if downloadedGuide != nil {
//                        GuideDetailInfoView(objectSteps: downloadedGuide?.objectSteps)
//                    } else {
//                        Text("To show the detailed steps, you need to download this guide.")
//                            .font(.system(size: 13).bold())
//                            .foregroundColor(.accentColor)
//                    }
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                if downloadedGuide != nil {
                    Text("This guide is already downloaded")
                        .font(.system(size: 13).bold())
                        .foregroundColor(.accentColor)
                } else {
                    Text("This guide is not downloaded yet")
                        .font(.system(size: 13).bold())
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            HStack {
                Button("Download guide") {
                    onGetGuideAction()
                }
                .buttonStyle(ButtonStyledOutline())
                .disabled(downloadedGuide != nil)
                
                Button("Begin guide") {
                    onSetCurrentGuideAction()
                }
                .buttonStyle(ButtonStyledFill())
                .disabled(downloadedGuide == nil)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color("backgroundColor"))
    }
}

struct GuideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GuideDetailView(guide: Guide.example, downloadedGuide: nil, onGetGuideAction: {}, onSetCurrentGuideAction: {})
    }
}
