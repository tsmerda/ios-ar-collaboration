//
//  ModeSquareView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 25.07.2023.
//

import SwiftUI

struct ModeSquareView: View {
    let mode: SelectedMode
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: mode == .online ? "icloud.and.arrow.down" : "wifi.slash")
                .font(.system(size: 40).weight(.light))
                .foregroundColor(isSelected ? .accentColor : .white)
                .padding(.bottom, 2)
            
            Text(mode == .online ? L.ChooseMode.online : L.ChooseMode.online)
                .font(.system(size: 17))
                .foregroundColor(isSelected ? .accentColor : .white)
            
            if mode == .online {
                Text(L.ChooseMode.notImplemented)
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

struct ModeSquareView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSquareView(mode: .none, isSelected: false)
    }
}
