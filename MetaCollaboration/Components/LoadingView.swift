//
//  LoadingView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.07.2023.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            ProgressView("Loading assets").foregroundColor(.accentColor)
                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                .scaleEffect(1.2)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
