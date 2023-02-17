//
//  InfoView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("English")
                    Text("Czech")
                } header: {
                    Text("Language")
                }
                
                Section {
                    HStack {
                        Text("Change app mode")
                        Spacer()
                        Button(action: {
                            viewModel.appMode = .none
                            UserDefaults.standard.set("none", forKey: "appMode")
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                        }
                    }
                } header: {
                    Text("Mode")
                }
                
                Section {
                    Text("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)")
                } header: {
                    Text("Version")
                }
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
