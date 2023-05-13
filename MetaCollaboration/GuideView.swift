//
//  GuideView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 02.03.2023.
//

import SwiftUI

struct GuideView: View {
    @Binding var guide: ExtendedGuide?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .foregroundColor(Color(.black))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(.black).opacity(0.5), lineWidth: 1)
                                .frame(width: 40, height: 40)
                        )
                }
            }
            
            Text(guide?.name ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            VStack {
                Text("Begin collaborative session")
                    .font(.system(.caption2).weight(.light))
                    .foregroundColor(.gray)
                
                Button(action: {
                    viewModel.arMode = activeARMode.collaborationMode
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arkit")
                            .imageScale(.large)
                            .foregroundColor(Color(.black))
                        
                        Text("SHOW MODEL")
                            .font(.caption.bold())
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(.black).opacity(0.5), lineWidth: 1)
                    )
                }
            }
            
            Divider()
                .padding(.vertical)
            
            Text(guide?._description ?? "")
                .font(.callout)
            
            
            Spacer()
        }
        .padding()
    }
}

struct GuideView_Previews: PreviewProvider {
    static var previews: some View {
        let guide = ExtendedGuide(_id: "640b700f16cde6145a3bfc19", name: "Upgrading old Prusa MK2s.", _description: "How to upgrade the old MK2s to MK2s+ featuring the cool magnetic heatbed.", imageUrl: "/images/guides/10/34.png", guideType: .manual)
        GuideView(guide: .constant(guide)) // pass a Binding of Guide instead of Guide instance
    }
}
