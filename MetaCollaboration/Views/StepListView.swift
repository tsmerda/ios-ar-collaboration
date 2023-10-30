//
//  StepListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI

struct StepListView: View {
    @StateObject private var viewModel: StepListViewModel
    @EnvironmentObject var nav: NavigationStateManager
    
    @State private var selection: String? = ""
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: StepListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // TODO: -- PRIDAT VIEW TITLE
    var body: some View {
        VStack(spacing: 0) {
            stepListTitle
            objectStepsList
            buttonsLabel
            buttonsStack
        }
        .onAppear {
            selection = viewModel.guide?.objectSteps?.first?.id
            // TODO: -- Nastavit selection podle currentStepId az se bude vracet spravne z BE
            // selection = currentStepId
        }
        .navigationTitle("Step list")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("backgroundColor")
            .ignoresSafeArea(.all, edges: .all))
    }
}

private extension StepListView {
    var stepListTitle: some View {
        HStack {
            Text("\(viewModel.guide?.name ?? "") step list")
                .bold()
                .font(.title)
            Spacer()
        }
        .padding()
    }
    var objectStepsList: some View {
        ScrollView {
            ForEach(viewModel.guide?.objectSteps ?? [], id: \.id) { step in
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
                .padding()
                .background(selection == step.id ? Color.accentColor.opacity(0.1) : Color.clear)
                .cornerRadius(8)
                //  TODO: -- disable tap gesture
                //  .onTapGesture {
                //      onSelectStep(step.order ?? 1)
                //      selection = step.id
                //  }
            }
        }
        .padding()
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
        VStack {
            HStack {
                Button("Previous") {
                    // TODO: -- Nastavit predesly step pokud je k dispozici (aktualni step.order - 1)
                    // onSelectStep(step.order ?? 1)
                }
                .buttonStyle(ButtonStyledFill())
                .disabled(true)
                Spacer()
                Button("Continue") {
                    dismiss()
                }
                .buttonStyle(ButtonStyledFill())
            }
            HStack {
                Button(action: {
                    nav.goBack()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Exit guide")
                    }
                }
                .buttonStyle(ButtonStyledOutline())
            }
            .padding(.top)
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
        viewModel: StepListViewModel(
            guide: ExtendedGuideResponse(
                name: "Guide",
                guideType: .tutorial,
                objectSteps: SimpleStep.exampleArray
            ),
            currentStepId: SimpleStep.example.id,
            onSelectStep: { _ in }
        )
    )
}
