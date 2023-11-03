//
//  FinalView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 03.11.2023.
//

import SwiftUI

struct FinalView: View {
    @EnvironmentObject var nav: NavigationStateManager
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                VStack {
                    Image(systemName: "fireworks")
                        .font(.system(size: 50).weight(.thin))
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    Text("Congratulations!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 8)
                    Text("You have successfully passed the tutorial.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
                Spacer()
                Button("Back to guide list") {
                    nav.popToRoot()
                }
                .buttonStyle(ButtonStyledFill())
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    FinalView()
}
