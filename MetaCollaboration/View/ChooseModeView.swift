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
                    SquareView(mode: .online, isSelected: selectedMode == .online)
                }
                .disabled(true)
                
                Button(action: {
                    selectedMode = .offline
                }) {
                    SquareView(mode: .offline, isSelected: selectedMode == .offline)
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

struct SquareView: View {
    let mode: SelectedMode
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: mode == .online ? "icloud.and.arrow.down" : "wifi.slash")
                .font(.system(size: 40).weight(.light))
                .foregroundColor(isSelected ? .accentColor : .white)
                .padding(.bottom, 2)
            
            Text(mode == .online ? "Online" : "Offline")
                .font(.system(size: 17))
                .foregroundColor(isSelected ? .accentColor : .white)
            
            if mode == .online {
                Text("NOT IMPLEMENTED")
                    .font(.system(size: 10).weight(.bold))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .frame(width: 150, height: 150)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
    }
}




// TODO: - Add styles to separate file
struct ButtonStyledFill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16).weight(.semibold))
            .foregroundStyle(.black)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(16)
    }
}

struct ButtonStyledOutline: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16).weight(.semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
    }
}


struct ChooseModeView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseModeView()
    }
}
