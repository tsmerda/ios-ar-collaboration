//
//  GuideView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 02.03.2023.
//

import SwiftUI

struct GuideView: View {
    //    @Binding var guide: ExtendedGuide?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: CollaborationViewModel
    @State private var selectedStep: Int = 0
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
            
            Text(viewModel.currentGuide?.name ?? "Upgrading old Prusa MK2s.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(.black))
                .padding(.bottom, 10)
            
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: viewModel.currentGuide?.imageUrl ?? "https://3dwithus.com/wp-content/uploads/2017/02/Prusa-i3-MK2-Before-Upgrade-to-MK2.5S.jpg")) { image in image.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray } .frame(width: 128, height: 128) .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(viewModel.currentGuide?._description ?? "How to upgrade the old MK2s to MK2s+ featuring the cool magnetic heatbed.")
                    .foregroundColor(Color(.black))
                    .font(.callout)
                
                Spacer()
            }
            
            Divider()
                .padding(.vertical)
            
            HStack {
                Text("Recognized object: ")
                    .font(.system(.caption).weight(.bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(viewModel.ARResults)
                    .font(.system(.caption).weight(.medium))
                    .foregroundColor(.cyan)
            }
            .padding(.bottom)
            
            // Horizontal list of steps
            HStack(spacing: 12) {
                ForEach((viewModel.currentGuide?.objectSteps!.indices)!, id: \.self) { index in
                    Button(action: {
                        selectedStep = index
                    }) {
                        VStack {
                            Text("\(index + 1)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(selectedStep == index ? .white : .cyan)
                                .frame(width: 48, height: 48)
                                .background(selectedStep == index ? Color.cyan : Color.cyan.opacity(0.2))
                                .clipShape(Circle())
                            
                            // Show DONE icon
                            
                            //                                            if mockObjectSteps[index].completed {
                            //                                                Image(systemName: "checkmark.circle.fill")
                            //                                                    .foregroundColor(.green)
                            //                                                    .padding(.top, 4)
                            //                                            }
                        }
                    }
                }
                Spacer()
            }
            
            VStack {
                HStack(alignment: .top) {
                    AsyncImage(url: URL(string: viewModel.currentGuide?.objectSteps![selectedStep].instruction?.imageUrl ?? "https://3dwithus.com/wp-content/uploads/2017/02/Prusa-i3-MK2-Before-Upgrade-to-MK2.5S.jpg")) { image in image.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray } .frame(width: 100, height: 100) .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading){
                        Text(viewModel.currentGuide?.objectSteps![selectedStep].instruction?.title ?? "")
                            .font(.system(.title3).weight(.medium))
                            .foregroundColor(.black)
                        
                        Text(viewModel.currentGuide?.objectSteps![selectedStep].instruction?.text ?? "")
                            .font(.system(.footnote).weight(.regular))
                            .foregroundColor(.black)
                        
                        HStack {
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
                                .padding(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color(.black).opacity(0.5), lineWidth: 1)
                                )
                            }
                            
                            Text("Begin collaborative session")
                                .font(.system(.caption2).weight(.light))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                ForEach((viewModel.currentGuide?.objectSteps![selectedStep].steps!.indices)!, id: \.self) { index in
                    HStack(alignment: .center) {
                        Image(systemName: "circle")
                            .imageScale(.medium)
                            .foregroundColor(Color(.black))
                        
                        Text(viewModel.currentGuide?.objectSteps![selectedStep].steps![index].contents[0].text ?? "")
                            .font(.system(.footnote).weight(.regular))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .padding(8)
            .background(Color.cyan.opacity(0.1))
            .cornerRadius(16)
            
            Spacer()
        }
        .padding()
    }
}

struct GuideView_Previews: PreviewProvider {
    static var previews: some View {
        let guide = ExtendedGuide(_id: "640b700f16cde6145a3bfc19", name: "Upgrading old Prusa MK2s.", _description: "How to upgrade the old MK2s to MK2s+ featuring the cool magnetic heatbed.", imageUrl: "/images/guides/10/34.png", guideType: .manual)
        GuideView() // pass a Binding of Guide instead of Guide instance
            .environmentObject(CollaborationViewModel())
    }
}
