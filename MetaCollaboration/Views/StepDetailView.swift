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
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 24, weight: .light))
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
