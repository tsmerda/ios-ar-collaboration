//
//  GuideView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 02.03.2023.
//

import SwiftUI

struct GuideView: View {
    @Binding var guide: Guide?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
            
            Text(guide?.name ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text(guide?._description ?? "")
                .font(.callout)
                .padding(.bottom, 10)
            
            
            Spacer()
        }
        .padding()
    }
}

//struct GuideView_Previews: PreviewProvider {
//    static var previews: some View {
//        GuideView()
//    }
//}
