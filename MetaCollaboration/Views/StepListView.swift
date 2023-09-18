//
//  StepListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI

struct StepListView: View {
    
    let guide: ExtendedGuideResponse?
    let currentStepId: String
    
    @State private var selection: String? = ""
    
    @AppStorage("collaborationMode") var collaborationMode: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            List(guide?.objectSteps ?? [], id: \.id, selection: $selection) { step in
                HStack(spacing: 8) {
                    Text(step.title ?? "Unknown title")
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    if selection == step.id {
                        Text("Selected".uppercased())
                            .font(.system(size: 11).weight(.bold))
                            .foregroundColor(.accentColor)
                            .padding(.trailing, 8)
                    }
                    
                    // TODO: - Pridat az bude hotovy BE vypis stepu podle confirmation
                    if true {
                        Image(systemName: "circle")
                            .font(.system(size: 24, weight: .light))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 24, weight: .light))
                    }
                }
                .padding(6)
                .listRowBackground(selection == step.id ? Color.accentColor.opacity(0.1) : Color.clear)
            }
            .scrollContentBackground(.hidden)
            
            HStack {
                Spacer()
                
                Text("Click continue to show guide info & collaboration, click arrow back to show previous step or exit this guide")
                    .font(.system(size: 13).bold())
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack() {
                Button(action: {
                    // TODO: - Zobrazit alert nez uzivatel zavre guide?
                    collaborationMode = false
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
                .buttonStyle(ButtonStyledOutline())
                .frame(width: 80)
                
                Spacer()
                
                Button(action: {
                    //                TODO: - previous selection
                    //                    selection = "63ef73307b425e2daf8c9081"
                }) {
                    Image(systemName: "arrow.left")
                        .imageScale(.large)
                }
                .buttonStyle(ButtonStyledFill())
                .frame(width: 80)
                
                Spacer()
                
                Button("Continue") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(ButtonStyledFill())
                .frame(width: 150)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        }
        .onAppear {
            selection = currentStepId
        }
        .navigationTitle("Step list")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("backgroundColor")
            .ignoresSafeArea(.all, edges: .all))
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color("backgroundColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct StepListView_Previews: PreviewProvider {
    static var previews: some View {
        StepListView(guide: ExtendedGuideResponse(name: "Name", guideType: .tutorial, objectSteps: SimpleStep.exampleArray), currentStepId: SimpleStep.example.id ?? "")
    }
}
