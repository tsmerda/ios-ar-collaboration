//
//  ImagePopupView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.09.2023.
//

import SwiftUI

struct ImagePopupView: View {
    @Binding var showImagePopup: Bool
    
    let imageUrl: String
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .ignoresSafeArea(.all)
            
            VStack {
                Spacer()
                
                AsyncImage(url: URL(string: imageUrl)){ image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: { Color("secondaryColor") }
                    .frame(width: .infinity, height: 300)
                    .frame(maxWidth: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                
                Spacer()
            }
        }
        .onTapGesture {
            showImagePopup.toggle()
        }
    }
}

struct ImagePopupView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePopupView(showImagePopup: .constant(true), imageUrl: "https://c-3d.niceshops.com/upload/image/product/large/default/bondtech-prusa-i3-mk2-mk2s-extruder-upgrade-1-ks-252884-cs.jpg")
    }
}
