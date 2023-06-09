//
//  ChooseModeView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 17.02.2023.
//

import SwiftUI

struct ChooseModeView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Please select the required mode")
                .font(.system(.title).weight(.light))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
            
            Text("Online mode provides recognition of scene objects on the server. In offline mode, you work with ML models downloaded to the device.")
                .font(.system(.caption2).weight(.light))
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
                .frame(maxWidth: 260)
            
            Button(action: {
//                UserDefaults.standard.set("onlineMode", forKey: "appMode")
//                viewModel.appMode = activeAppMode.onlineMode
            }) {
                SquareView(icon: "icloud.and.arrow.down", text: "Online")
            }
            
            Button(action: {
                UserDefaults.standard.set("offlineMode", forKey: "appMode")
                viewModel.appMode = activeAppMode.offlineMode
            }) {
                SquareView(icon: "platter.filled.bottom.and.arrow.down.iphone", text: "Offline")
            }
            
        }
        .padding()
    }
}

struct SquareView: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 48).weight(.thin))
                .foregroundColor(text == "Online" ? .gray : .green)
            Text(text)
                .font(.system(.headline).weight(.light))
                .foregroundColor(text == "Online" ? .gray : .green)
            if text == "Online" {
                Text("NOT IMPLEMENTED")
                    .font(.system(.caption2).weight(.bold))
                    .foregroundColor(.gray)
                    .padding(.trailing, 2)
            }
        }
        .frame(width: 150, height: 150)
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ChooseModeView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseModeView()
    }
}
