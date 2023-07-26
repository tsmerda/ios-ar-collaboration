//
//  GuideDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct GuideDetailView: View {
    @AppStorage("collaborationMode") var collaborationMode: Bool = false
    
    var guide: Guide?
    var isDownloaded: Bool
    var downloadedAssets: [String] = []
    
    let onGetGuideAction: () -> Void
    //    @Binding var currentGuide: ExtendedGuide?
    
    var body: some View {
//    TODO: - Pridat scroll view kvuli posouvani textu a zalamovani nadpisu
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(guide?.name ?? "Guide name")
                    .font(.system(size: 32).bold())
                    .foregroundColor(.white)
                    .padding(.bottom, 26)
                
                Text(guide?.description ?? "Guide description")
                    .font(.subheadline)
                    .foregroundColor(Color("disabledColor"))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 32)
                
                AsyncImage(url: URL(string: guide?.imageUrl ?? "")){ image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(8)
                } placeholder: { Color.gray }
                    .frame(width: .infinity, height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 24)
                
                if isDownloaded {
                    GuideDetailInfoView()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    if isDownloaded {
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
                .padding(.bottom, 8)
                
                HStack {
                    Button("Download guide") {
                        onGetGuideAction()
                    }
                    .buttonStyle(ButtonStyledOutline())
                    .disabled(isDownloaded)
                    
                    Button("Begin guide") {
                        collaborationMode = true
                    }
                    .buttonStyle(ButtonStyledFill())
                    .disabled(!isDownloaded)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color("backgroundColor"))
    }
}

struct GuideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GuideDetailView(isDownloaded: false, onGetGuideAction: {})
    }
}
