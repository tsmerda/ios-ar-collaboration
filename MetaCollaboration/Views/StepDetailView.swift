//
//  StepDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI

struct StepDetailView: View {
    @StateObject private var viewModel: StepDetailViewModel
    
    //    @Binding var guide: ExtendedGuide?
    //    @State private var selectedStep: Int = 0
    //    @State private var isConfirmed: Bool = false
    
    init(viewModel: StepDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                instructionText
                titleRow
                descriptionText
            }
            .padding()
            
            if let steps = viewModel.currentStep?.steps {
                List {
                    Section(header: Text("Tasks")) {
                        ForEach(steps, id: \.id) { step in
                            stepRow(step)
                        }
                        .listRowBackground(Color("secondaryColor"))
                    }
                    .headerProminence(.increased)
                }
            }
            Spacer()
            confirmButton
        }
        .scrollContentBackground(.hidden)
        .background(Color("backgroundColor")
            .ignoresSafeArea(.all, edges: .all))
    }
}

private extension StepDetailView {
    var instructionText: some View {
        Text("Instructions".uppercased())
            .font(.system(size: 10).weight(.bold))
            .foregroundColor(Color("disabledColor"))
            .padding(.top)
    }
    var titleRow: some View {
        HStack {
            Text("Removing screw")
                .font(.system(size: 20).weight(.bold))
                .foregroundColor(.accentColor)
            Spacer()
            Text("Step: \(viewModel.currentStep?.order ?? 0)/2")
                .font(.system(size: 12).weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(24)
        }
    }
    var descriptionText: some View {
        Text("Remove the M3 screw from the fan holder. Remove the M3 screw from the fan holder. Remove the M3 screw from the fan holder")
            .font(.system(size: 16))
            .foregroundColor(Color("disabledColor"))
    }
    func stepRow(_ step: Step) -> some View {
        HStack(alignment: .top, spacing: 8) {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(step.contents ?? [], id: \.order) { content in
                    // TODO: -- az bude vracet BE
                    // if content.contentType == .textblock {
                    Text(content.text ?? "")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    // }
                }
            }
            Spacer()
            Button(action: {
                viewModel.toggleStepDone(step)
            }) {
                Image(systemName: (step.confirmation?.done ?? false) ? "checkmark.circle" : "circle")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 24, weight: .light))
            }
        }
    }
    var confirmButton: some View {
        Button("Confirm step") {
            viewModel.onNavigateAction()
        }
        .buttonStyle(ButtonStyledFill())
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}

#Preview {
    StepDetailView(
        viewModel: StepDetailViewModel(
            currentStep: ObjectStep.example,
            onNavigateAction: {},
            toggleStepDone: { _ in }
        )
    )
    .presentationDetents([.height(180), .medium])
    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
    .interactiveDismissDisabled()
    .presentationDragIndicator(.automatic)
}
