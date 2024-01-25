//
//  StepDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI

struct StepDetailView: View {
    @StateObject private var viewModel: StepDetailViewModel
    private let progressHudBinding: ProgressHudBinding
    
    init(viewModel: StepDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                instructionText
                titleRow
                descriptionText
            }
            .padding()
            Divider()
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
        Text(L.StepDetail.instructions.uppercased())
            .font(.system(size: 10).weight(.bold))
            .foregroundColor(Color("disabledColor"))
            .padding(.top)
    }
    var titleRow: some View {
        HStack(alignment: .top) {
            Text(viewModel.currentStep?.instruction?.title ?? L.Generic.unknown)
                .font(.system(size: 20).weight(.bold))
                .foregroundColor(.accentColor)
            Spacer()
            Text("\(L.StepDetail.step)\(String(describing: viewModel.currentStep?.order ?? 0))")
                .font(.system(size: 12).weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(24)
        }
    }
    var descriptionText: some View {
        Text(viewModel.currentStep?.instruction?.text ?? L.Generic.unknown)
            .font(.system(size: 16))
            .foregroundColor(Color("disabledColor"))
    }
    @ViewBuilder
    var tasksWithPreview: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Task Section
                if let steps = viewModel.currentStep?.steps {
                    VStack(alignment: .leading) {
                        Text(L.StepDetail.tasks)
                            .font(.title)
                            .padding(.top)
                        VStack {
                            ForEach(steps, id: \.self) { step in
                                stepRow(step)
                                if step != steps.last {
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color("secondaryColor"))
                        .cornerRadius(8)
                    }
                }
                // Preview Image Section
                if let imageUrl = viewModel.currentStep?.instruction?.imageUrl {
                    VStack(alignment: .leading) {
                        Text(L.StepDetail.preview)
                            .font(.title)
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                                    .frame(maxWidth: .infinity)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
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
        .padding(.vertical, 4)
    }
    var confirmButton: some View {
        Button(L.StepDetail.confirm) {
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
    .presentationDetents([.height(180), .large])
    .presentationBackgroundInteraction(.enabled)
    .interactiveDismissDisabled()
    .presentationDragIndicator(.automatic)
}
