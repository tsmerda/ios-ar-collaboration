//
//  SettingsView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: CollaborationViewModel
    @AppStorage("appMode") var appMode: ActiveAppMode = .none
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // MARK: - SECTION 1
                    GroupBox(
                        label:
                            SettingsLabelView(labelText: "Meta Collaboration", labelImage: "info.circle")
                    ) {
                        Divider().padding(.vertical, 4)
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .cornerRadius(9)
                            
                            Text("Discover a cutting-edge iOS app for collaborative augmented reality experiences. Share and manipulate scenes in real-time, leveraging ARKit, RealityKit, and MultipeerConnectivity. Experience the future of AR with seamless usability and potential for further development in the metaverse.")
                                .font(.footnote)
                        }
                    }
                    .backgroundStyle(Color("secondaryColor"))
                    
                    // MARK: - SECTION 2
                    
                    GroupBox(
                        label:
                            SettingsLabelView(labelText: "Application", labelImage: "apps.iphone")
                    ) {
                        SettingsRowView(name: "Developer", content: "Tomáš Šmerda")
                        SettingsRowView(name: "Designer", content: "Tomáš Šmerda")
                        SettingsRowView(name: "Compatibility", content: "iOS 16")
                        SettingsRowView(name: "SwiftUI", content: "4.0")
                        SettingsRowView(name: "Website", linkLabel: "Spatial Hub @ MENDELU", linkDestination: "spatialhub.mendelu.cz")
                        SettingsRowView(name: "LinkedIn", linkLabel: "tomas-smerda-708a1b1a1", linkDestination: "linkedin.com/in/tomas-smerda-708a1b1a1")
                        SettingsRowView(name: "Version", content: "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)")
                    }
                    .backgroundStyle(Color("secondaryColor"))
                    
                    // MARK: - SECTION 3
                    
                    GroupBox(
                        label: SettingsLabelView(labelText: "Customization", labelImage: "paintbrush")
                    ) {
                        Divider().padding(.vertical, 4)
                        
                        HStack(alignment: .center, spacing: 10) {
                            Text("Online mode activated")
                                .foregroundColor(.gray)
                            Spacer()
                            if appMode == .onlineMode {
                                Image(systemName: "circle.inset.filled")
                                    .foregroundColor(.accentColor)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        HStack(alignment: .center, spacing: 10) {
                            Text("Offline mode activated")
                                .foregroundColor(.gray)
                            Spacer()
                            if appMode == .offlineMode {
                                Image(systemName: "circle.inset.filled")
                                    .foregroundColor(.accentColor)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("If you wish, you can remove all guides from this device using the button below.")
                            .padding(.vertical, 8)
                            .frame(minHeight: 60)
                            .layoutPriority(1)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                        
                        Button(action: {
                            viewModel.removeDatasetFromLocalStorage()
                        }) {
                            Text("Remove all")
                                .fontWeight(.bold)
                                .foregroundColor(Color("errorColor"))
                        }
                        .padding()
                        .background(
                            Color("dividerColor")
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        )
                    }
                    .backgroundStyle(Color("secondaryColor"))
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .padding()
            }
            .background(Color("backgroundColor"))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CollaborationViewModel())
    }
}
