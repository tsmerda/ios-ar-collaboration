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
    
    @State private var selection: Decimal? = 0
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: StepListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            stepListTitle
            objectStepsList
            buttonsLabel
            buttonsStack
        }
        .onAppear {
            if let stepOrder = viewModel.stepOrder {
                selection = stepOrder
            }
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
                    if selection == step.order {
                        Text("Selected".uppercased())
                            .font(.system(size: 11).weight(.bold))
                            .foregroundColor(.accentColor)
                            .padding(.trailing, 8)
                    }
                    if step.confirmation?.done == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 24, weight: .light))
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 24, weight: .light))
                    }
                }
                .padding()
                .background(selection == step.order ? Color.accentColor.opacity(0.1) : Color.clear)
                .cornerRadius(8)
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
                    viewModel.onSelectPreviousStep()
                    dismiss()
                }
                .buttonStyle(ButtonStyledFill())
                .disabled(viewModel.stepOrder == 1)
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
            stepOrder: 1,
            onSelectPreviousStep: {}
        )
    )
}
