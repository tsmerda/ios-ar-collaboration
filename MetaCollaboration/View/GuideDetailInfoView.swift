//
//  GuideDetailInfoView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import SwiftUI

struct GuideDetailInfoView: View {
    var body: some View {
        GroupBox() {
            DisclosureGroup("Detailed information") {
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Group {
                        Image(systemName: "info.circle")
                        Text("Guide type")
                    }
                    .foregroundColor(.accentColor)
                    .font(.system(.body).bold())
                    
                    Spacer(minLength: 25)
                    
                    Text("Manual")
                        .multilineTextAlignment(.trailing)
                }
                
                Divider()
                    .padding(.vertical, 2)
                
                HStack {
                    Group {
                        Image(systemName: "info.circle")
                        Text("Steps")
                    }
                    .foregroundColor(.accentColor)
                    .font(.system(.body).bold())
                    
                    Spacer(minLength: 25)
                    
                    Text("2")
                        .multilineTextAlignment(.trailing)
                }
                
                Divider()
                    .padding(.vertical, 2)
                
                HStack {
                    Group {
                        Image(systemName: "info.circle")
                        Text("Assets")
                    }
                    .foregroundColor(.accentColor)
                    .font(.system(.body).bold())
                    
                    Spacer(minLength: 25)
                    
                    Text("3")
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .backgroundStyle(Color("secondaryColor"))
    }
}

struct GuideDetailInfoView_Previews: PreviewProvider {
    static var previews: some View {
        GuideDetailInfoView()
    }
}



//                                Text("Guide type:")
//                                    .font(.system(size: 15, weight: .light))
//                                    .foregroundColor(Color("disabledColor"))
//
//                                Spacer()
//
//                                Text(guide?.guideType.rawValue ?? "<guideType>")
//                                    .font(.system(size: 15, weight: .medium))
//                                    .foregroundColor(.white)
//                            }
//                            .listRowBackground(Color("secondaryColor"))
//
//                            HStack {
//                                Text("Steps:")
//                                    .font(.system(size: 15, weight: .light))
//                                    .foregroundColor(Color("disabledColor"))
//
//                                Spacer()
//
//                                Text("0")
//                                    .font(.system(size: 15, weight: .medium))
//                                    .foregroundColor(.white)
//
//                                if downloadedAssets != [] {
//                                    Section(header: Text("Assets").foregroundColor(Color("disabledColor"))) {
//                                        ForEach(downloadedAssets, id: \.self) { asset in
//                                            HStack(spacing: 8) {
//                                                Text("arobject")
//                                                    .font(.system(size: 15, weight: .light))
//                                                    .foregroundColor(Color("disabledColor"))
//
//                                                Spacer()
//
//                                                Text(asset)
//                                                    .font(.system(size: 15, weight: .medium))
//                                                    .foregroundColor(.white)
//
//                                                // TODO: -- Add asset description
//                                            }
//                                            .listRowBackground(Color("secondaryColor"))
//                                        }
//                                    }
//                                }

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
