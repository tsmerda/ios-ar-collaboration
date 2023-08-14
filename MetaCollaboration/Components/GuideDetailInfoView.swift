//
//  GuideDetailInfoView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.07.2023.
//

import SwiftUI

struct GuideDetailInfoView: View {
    
    let objectSteps: [ObjectStep]?
    
    var body: some View {
        GroupBox() {
            DisclosureGroup("Detailed steps information") {
                
                
                ForEach(objectSteps ?? [], id: \.order) { step in
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack {
                        Group {
                            if step.order != nil {
                                Image(systemName: "\(step.order!).circle")
                            }
                            Text(step.title ?? "Unknown title")
                        }
                        .foregroundColor(.white)
                        .font(.system(.body))
                        
                        Spacer()
                    }
                }
            }
        }
        .backgroundStyle(Color("secondaryColor"))
    }
}

struct GuideDetailInfoView_Previews: PreviewProvider {
    static var previews: some View {
        GuideDetailInfoView(objectSteps: ObjectStep.exampleArray)
    }
}
