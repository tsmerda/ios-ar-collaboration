//
//  SettingsView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    private let removeAllFromLocalStorage: () -> Void
    //    @AppStorage("appMode") var appMode: ActiveAppMode = .none

    init(removeAllFromLocalStorage: @escaping () -> Void) {
        self.removeAllFromLocalStorage = removeAllFromLocalStorage
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    appDescriptionView
                    appAuthorView
                    appDetailedInfoView
                    appCustomizationView
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            dismiss()
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

private extension SettingsView {
    var appDescriptionView: some View {
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
    }
    var appAuthorView: some View {
        GroupBox(
            label:
                SettingsLabelView(labelText: "Author", labelImage: "person")
        ) {
            Divider().padding(.vertical, 4)
            
            HStack(alignment: .center, spacing: 10) {
                Image("author")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("Tomáš Šmerda")
                        .foregroundColor(.gray)
                        .bold()
                    HStack {
                        Text("LinkedIn")
                            .foregroundColor(.gray)
                        Spacer()
                        Link("tomas-smerda", destination: URL(string: "https://linkedin.com/in/tomas-smerda")!)
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.pink)
                    }
                }
            }
        }
        .backgroundStyle(Color("secondaryColor"))
    }
    var appDetailedInfoView: some View {
        GroupBox(
            label:
                SettingsLabelView(labelText: "Application", labelImage: "apps.iphone")
        ) {
            SettingsRowView(name: "Compatibility", content: "iOS 16")
            SettingsRowView(name: "SwiftUI", content: "4.0")
            SettingsRowView(name: "Website", linkLabel: "Spatial Hub @ MENDELU", linkDestination: "spatialhub.mendelu.cz")
            SettingsRowView(name: "App version", content: "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)")
        }
        .backgroundStyle(Color("secondaryColor"))
    }
    var appCustomizationView: some View {
        GroupBox(
            label: SettingsLabelView(labelText: "Customization", labelImage: "paintbrush")
        ) {
            Divider().padding(.vertical, 4)
            
            HStack(alignment: .center, spacing: 10) {
                Text("Online mode activated")
                    .foregroundColor(.gray)
                Spacer()
                // if appMode == .onlineMode {
                Image(systemName: "circle.inset.filled")
                    .foregroundColor(.accentColor)
                // } else {
                //      Image(systemName: "circle")
                //      .foregroundColor(.accentColor)
                // }
            }
            
            Divider().padding(.vertical, 4)
            
            HStack(alignment: .center, spacing: 10) {
                Text("Offline mode activated")
                    .foregroundColor(.gray)
                Spacer()
                // if appMode == .offlineMode {
                //    Image(systemName: "circle.inset.filled")
                //      .foregroundColor(.accentColor)
                // } else {
                Image(systemName: "circle")
                    .foregroundColor(.accentColor)
                // }
            }
            
            Divider().padding(.vertical, 4)
            
            Text("If you wish, you can remove all guides from this device using the button below.")
                .padding(.vertical, 8)
                .frame(minHeight: 60)
                .layoutPriority(1)
                .font(.footnote)
                .multilineTextAlignment(.leading)
            
            Button(action: {
                removeAllFromLocalStorage()
            }) {
                Text("Remove all")
                    .fontWeight(.bold)
                    .foregroundColor(Color("errorColor"))
            }
            // TODO: -- make button disabled if there are no assets
            //                        .disabled(viewModel.downloadedAssets.isEmpty)
            .padding()
            .background(
                Color("dividerColor")
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            )
        }
        .backgroundStyle(Color("secondaryColor"))
    }
}

#Preview {
    SettingsView(removeAllFromLocalStorage: {})
}
