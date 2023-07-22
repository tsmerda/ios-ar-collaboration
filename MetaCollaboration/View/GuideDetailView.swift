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
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(guide?.name ?? "Guide name")
                    .font(.system(size: 32).bold())
                    .foregroundColor(.white)
                    .padding(.bottom, 26)
                
                Text(guide?._description ?? "Guide description")
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
                
                if isDownloaded {
                    List {
                        Section(header: Text("General info").foregroundColor(Color("disabledColor"))) {
                            HStack {
                                Text("Guide type:")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Color("disabledColor"))
                                
                                Spacer()
                                
                                Text(guide?.guideType.rawValue ?? "<guideType>")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color("secondaryColor"))
                            
                            HStack {
                                Text("Steps:")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Color("disabledColor"))
                                
                                Spacer()
                                
                                Text("0")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                
                                // TODO: - Po updatu BE aktualizovat steps count
                                //                                if guide?.objectSteps != nil {
                                //                                    Text(guide?.objectSteps?.count ?? "")
                                //                                        .font(.system(size: 15, weight: .medium))
                                //                                        .foregroundColor(.white)
                                //                                } else {
                                //                                    Text("0")
                                //                                        .font(.system(size: 15, weight: .medium))
                                //                                        .foregroundColor(.white)
                                //                                }
                            }
                            .listRowBackground(Color("secondaryColor"))
                        }
                        
                        if downloadedAssets != [] {
                            Section(header: Text("Assets").foregroundColor(Color("disabledColor"))) {
                                ForEach(downloadedAssets, id: \.self) { asset in
                                    HStack(spacing: 8) {
                                        Text("arobject")
                                            .font(.system(size: 15, weight: .light))
                                            .foregroundColor(Color("disabledColor"))
                                        
                                        Spacer()
                                        
                                        Text(asset)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        // TODO: -- Add asset description
                                    }
                                    .listRowBackground(Color("secondaryColor"))
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
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
