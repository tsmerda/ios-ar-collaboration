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
                .navigationTitle(L.Settings.title)
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
                SettingsLabelView(labelText: L.Settings.appName, labelImage: "info.circle")
        ) {
            Divider().padding(.vertical, 4)
            
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor)
                    .frame(width: 65, height: 65)
                    .overlay(
                        Image("logoAR")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(9)
                    )
                
                
                
                Text(L.Settings.description)
                    .font(.footnote)
            }
        }
        .backgroundStyle(Color("secondaryColor"))
    }
    var appAuthorView: some View {
        GroupBox(
            label:
                SettingsLabelView(labelText: L.Settings.author, labelImage: "person")
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
                        Text(L.Settings.linkedin)
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
                SettingsLabelView(labelText: L.Settings.app, labelImage: "apps.iphone")
        ) {
            SettingsRowView(name: L.Settings.compatibility, content: "iOS 16")
            SettingsRowView(name: L.Settings.swiftui, content: "4.0")
            SettingsRowView(name: L.Settings.website, linkLabel: "Spatial Hub @ MENDELU", linkDestination: "spatialhub.mendelu.cz")
            SettingsRowView(name: L.Settings.version, content: "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)")
        }
        .backgroundStyle(Color("secondaryColor"))
    }
    var appCustomizationView: some View {
        GroupBox(
            label: SettingsLabelView(labelText: L.Settings.customization, labelImage: "paintbrush")
        ) {
            Divider().padding(.vertical, 4)
            
            HStack(alignment: .center, spacing: 10) {
                Text(L.Settings.onlineMode)
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
                Text(L.Settings.offlineMode)
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
            
            Text(L.Settings.removeText)
                .padding(.vertical, 8)
                .frame(minHeight: 60)
                .layoutPriority(1)
                .font(.footnote)
                .multilineTextAlignment(.leading)
            
            Button(action: {
                removeAllFromLocalStorage()
            }) {
                Text(L.Settings.removeButton)
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
