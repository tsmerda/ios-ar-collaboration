//
//  ChooseModeView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.02.2023.
//

import SwiftUI

enum SelectedMode {
    case none
    case online
    case offline
}

struct ChooseModeView: View {
    @AppStorage("appMode") var appMode: ActiveAppMode = .none
    @State private var selectedMode: SelectedMode = .none
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Please select the required mode")
                .font(.system(size: 32).bold())
                .foregroundColor(.white)
                .padding(.vertical, 32)
            
            HStack() {
                Image(systemName: "info.circle")
                    .font(.system(size: 24).weight(.light))
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text("Online mode provides recognition of scene objects on the server. In offline mode, you work with ML models downloaded to the device.")
                    .font(.system(size: 12).weight(.light))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(Color("secondaryColor"))
            .cornerRadius(8)
            .padding(.bottom, 80)
            
            HStack(spacing: 24) {
                Spacer()
                
                Button(action: {
                    selectedMode = .online
                }) {
                    ModeSquareView(mode: .online, isSelected: selectedMode == .online)
                }
                .disabled(true)
                
                Button(action: {
                    selectedMode = .offline
                }) {
                    ModeSquareView(mode: .offline, isSelected: selectedMode == .offline)
                }
                
                Spacer()
                
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Choose mode") {
                    appMode = selectedMode == .online ? .onlineMode : .offlineMode
                }
                .buttonStyle(ButtonStyledFill())
                .padding(.bottom, 40)
                
                Spacer()
            }
            
        }
        .padding(16)
        .background(Color("backgroundColor"))
    }
}

struct ChooseModeView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseModeView()
    }
}
