//
//  StepDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI

struct StepDetailView: View {
    //    @Binding var guide: ExtendedGuide?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    @State private var selectedStep: Int = 0
    @State private var isConfirmed: Bool = false
    
    let onNavigateAction: () -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions".uppercased())
                    .font(.system(size: 10).weight(.bold))
                    .foregroundColor(Color("disabledColor"))
                    .padding(.top)
                
                HStack {
                    Text("Removing screw")
                        .font(.system(size: 20).weight(.bold))
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    Text("Step: 1/2")
                        .font(.system(size: 12).weight(.light))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(24)
                }
                
                Text("Remove the M3 screw from the fan holder. Remove the M3 screw from the fan holder. Remove the M3 screw from the fan holder")
                    .font(.system(size: 16))
                    .foregroundColor(Color("disabledColor"))
            }
            .padding()
            
            List {
                Section(header: Text("Tasks").foregroundColor(Color("disabledColor"))) {
                    ForEach(0..<2) { step in
                        HStack(spacing: 8) {
                            Text("First, check that you have a screwdriver.")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            // TODO: - Pridat az bude hotovy BE vypis stepu podle confirmation
                            if true {
                                Image(systemName: "circle")
                                    .font(.system(size: 24, weight: .light))
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color("secondaryColor"))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            
            Spacer()
                        
            HStack {
                Spacer()
                
                Button("Confirm step") {
                    onNavigateAction()
                }
                .buttonStyle(ButtonStyledFill())
                
                Spacer()
            }
        }
        .background(Color("backgroundColor")
            .ignoresSafeArea(.all, edges: .all))
    }
}

struct StepDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StepDetailView(onNavigateAction: {}).environmentObject(CollaborationViewModel())
    }
}




//struct StepDetailView: View {
//    //    @Binding var guide: ExtendedGuide?
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var viewModel: CollaborationViewModel
//    @State private var selectedStep: Int = 0
//
//    var body: some View {
//        VStack(alignment: .center) {
//            HStack {
//                Spacer()
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "xmark")
//                        .imageScale(.medium)
//                        .foregroundColor(Color(.black))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                                .stroke(Color(.black).opacity(0.5), lineWidth: 1)
//                                .frame(width: 40, height: 40)
//                        )
//                }
//            }
//
//            Text(viewModel.currentGuide?.name ?? "Upgrading old Prusa MK2s.")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(Color(.black))
//                .padding(.bottom, 10)
//
//            HStack(alignment: .top) {
////            TODO: -- change image
//                AsyncImage(url: URL(string: viewModel.currentGuide?.imageUrl ?? "https://3dwithus.com/wp-content/uploads/2017/02/Prusa-i3-MK2-Before-Upgrade-to-MK2.5S.jpg")) { image in image.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray } .frame(width: 128, height: 128) .clipShape(RoundedRectangle(cornerRadius: 16))
//
//                Text(viewModel.currentGuide?._description ?? "How to upgrade the old MK2s to MK2s+ featuring the cool magnetic heatbed.")
//                    .foregroundColor(Color(.black))
//                    .font(.callout)
//
//                Spacer()
//            }
//
//            Divider()
//                .padding(.vertical)
//
//            HStack {
//                Text("Recognized object: ")
//                    .font(.system(.caption).weight(.bold))
//                    .foregroundColor(.black)
//
//                Spacer()
//
//                Text(viewModel.currentGuide?.name ?? "None")
//                    .font(.system(.caption).weight(.medium))
//                    .foregroundColor(.cyan)
//            }
//            .padding(.bottom)
//
////        TODO: - Tady budou steps ne objectSteps
//            // Horizontal list of steps
////            HStack(spacing: 12) {
////                ForEach((viewModel.currentGuide?.objectSteps!.indices)!, id: \.self) { index in
////                    Button(action: {
////                        selectedStep = index
////                    }) {
////                        VStack {
////                            Text("\(index + 1)")
////                                .font(.system(size: 24, weight: .bold))
////                                .foregroundColor(selectedStep == index ? .white : .cyan)
////                                .frame(width: 48, height: 48)
////                                .background(selectedStep == index ? Color.cyan : Color.cyan.opacity(0.2))
////                                .clipShape(Circle())
////
////                            // Show DONE icon
////
////                            //                                            if mockObjectSteps[index].completed {
////                            //                                                Image(systemName: "checkmark.circle.fill")
////                            //                                                    .foregroundColor(.green)
////                            //                                                    .padding(.top, 4)
////                            //                                            }
////                        }
////                    }
////                }
////                Spacer()
////            }
//
//            VStack {
//                HStack(alignment: .top) {
//                    AsyncImage(url: URL(string: viewModel.currentGuide?.objectSteps![selectedStep].instruction?.imageUrl ?? "https://3dwithus.com/wp-content/uploads/2017/02/Prusa-i3-MK2-Before-Upgrade-to-MK2.5S.jpg")) { image in image.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray } .frame(width: 100, height: 100) .clipShape(RoundedRectangle(cornerRadius: 16))
//
//                    VStack(alignment: .leading){
//                        Text(viewModel.currentGuide?.objectSteps![selectedStep].instruction?.title ?? "")
//                            .font(.system(.title3).weight(.medium))
//                            .foregroundColor(.black)
//
//                        Text(viewModel.currentGuide?.objectSteps![selectedStep].instruction?.text ?? "")
//                            .font(.system(.footnote).weight(.regular))
//                            .foregroundColor(.black)
//                    }
//                }
//
//                ForEach((viewModel.currentGuide?.objectSteps![selectedStep].steps!.indices)!, id: \.self) { index in
//                    HStack(alignment: .center) {
//                        Image(systemName: "circle")
//                            .imageScale(.medium)
//                            .foregroundColor(Color(.black))
//
//                        Text(viewModel.currentGuide?.objectSteps![selectedStep].steps![index].contents[0].text ?? "")
//                            .font(.system(.footnote).weight(.regular))
//                            .foregroundColor(.black)
//
//                        Spacer()
//                    }
//                    .padding(8)
//                }
//            }
//            .padding(8)
//            .background(Color.cyan.opacity(0.1))
//            .cornerRadius(16)
//
//            Spacer()
//        }
//        .padding()
//    }
//}

//VStack {
//                                if let peerNames = viewModel.multipeerSession?.peerDisplayNames, !(viewModel.multipeerSession?.peerDisplayNames.isEmpty)! {
//                                    // array is not empty
//                                    Text("Connected peers")
//                                        .fontWeight(.bold)
//
//                                    ForEach(peerNames, id: \.self) { displayName in
//                                        Text(displayName)
//                                    }
//                                } else {
//                                    // array is empty or nil
//                                    Text("Currently no peers connected")
//                                        .fontWeight(.bold)
//                                }
//                            }
