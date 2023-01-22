//
//  InfoView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct InfoView: View {
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
