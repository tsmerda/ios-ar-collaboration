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
    let onSelectStep: (Int) -> Void
    
    @State private var selection: String? = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            objectStepsList
            buttonsLabel
            buttonsStack
        }
        .onAppear {
            selection = guide?.objectSteps?.first?.id
            // TODO: -- Nastavit selection podle currentStepId az se bude vracet spravne z BE
            // selection = currentStepId
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

private extension StepListView {
    var objectStepsList: some View {
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
                //  TODO: - Pridat az bude hotovy BE vypis stepu podle confirmation
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
            //  TODO: -- disable tap gesture
            //  .onTapGesture {
            //      onSelectStep(step.order ?? 1)
            //      selection = step.id
            //  }
        }
        .scrollContentBackground(.hidden)
    }
    var buttonsLabel: some View {
        HStack {
            Spacer()
            Text("Click continue to show guide info & collaboration or select previous step")
                .font(.system(size: 13).bold())
                .foregroundColor(.accentColor)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    var buttonsStack: some View {
        HStack {
            Button(action: {
                // TODO: -- Nastavit predesly step pokud je k dispozici (aktualni step.order - 1)
                // onSelectStep(step.order ?? 1)
            }) {
                Image(systemName: "arrow.left")
                    .imageScale(.large)
            }
            .buttonStyle(ButtonStyledOutline())
            .frame(width: 80)
            Spacer()
            Button("Continue") {
                dismiss()
            }
            .buttonStyle(ButtonStyledFill())
            .frame(width: 150)
        }
        .padding(
            EdgeInsets(
                top: 8,
                leading: 16,
                bottom: 16,
                trailing: 16
            )
        )
    }
}

#Preview {
    StepListView(
        guide: ExtendedGuideResponse(
            name: "Name",
            guideType: .tutorial,
            objectSteps: SimpleStep.exampleArray
        ),
        currentStepId: SimpleStep.example.id,
        onSelectStep: { _ in })
}
