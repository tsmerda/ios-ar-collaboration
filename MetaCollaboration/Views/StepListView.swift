//
//  StepListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI

struct StepListView: View {
    let guide: ExtendedGuide
    
    var body: some View {
        ZStack {
            List{
                ForEach(guide.objectSteps ?? []) { step in
                    HStack(spacing: 8) {
                        Text(step.instruction?.title ?? "Step")
                            .font(.system(size: 15))
                        
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
                    .foregroundColor(.white)
                    .listRowBackground(Color("backgroundColor"))
                }
            }
            .scrollContentBackground(.hidden)
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
        StepListView(guide: ExtendedGuide(name: "Name", guideType: .tutorial, objectSteps: []))
    }
}
