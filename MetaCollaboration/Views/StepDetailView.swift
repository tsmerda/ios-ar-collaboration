//
//  StepDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI

struct StepDetailView: View {
    @StateObject private var viewModel: StepDetailViewModel
    
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
            tasksWithPreview
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
            Text(viewModel.currentStep?.instruction?.title ?? "Current step title")
                .font(.system(size: 20).weight(.bold))
                .foregroundColor(.accentColor)
            Spacer()
            Text("Step: \(String(describing: viewModel.currentStep?.order ?? 0))/2")
                .font(.system(size: 12).weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(24)
        }
    }
    var descriptionText: some View {
        Text(viewModel.currentStep?.instruction?.text ?? "Current step text")
            .font(.system(size: 16))
            .foregroundColor(Color("disabledColor"))
    }
    @ViewBuilder
    var tasksWithPreview: some View {
        List {
            // Task Section
            if let steps = viewModel.currentStep?.steps {
                Section(header: Text("Tasks")) {
                    ForEach(steps, id: \.self) { step in
                        stepRow(step)
                    }
                    .listRowBackground(Color("secondaryColor"))
                }
                .headerProminence(.increased)
            }
        
            // Preview Image Section
            if let imageUrl = viewModel.currentStep?.instruction?.imageUrl {
                Section(header: Text("Preview image")) {
                    AsyncImage(url: URL(string: imageUrl)){ image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                    } placeholder: { Color("secondaryColor") }
                }
                .headerProminence(.increased)
            }
        }
    }

    func stepRow(_ step: Step) -> some View {
        HStack(alignment: .top, spacing: 8) {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(step.contents, id: \.self) { content in
                    if content.contentType == .textblock {
                        Text(content.text ?? "")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }
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
