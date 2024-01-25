//
//  CollaborationView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct CollaborationView: View {
    @StateObject private var viewModel: CollaborationViewModel
    
    @EnvironmentObject var nav: NavigationStateManager
    
    @State private var showStepSheet: Bool = false
    @State private var showStepListSheet: Bool = true
    @State private var showConfirmationView: Bool = false
    
    private let progressHudBinding: ProgressHudBinding
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    init(
        viewModel: CollaborationViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        ZStack {
            arViewContainer
        }
        .overlay(alignment: .top, content: {
            infoLabel
        })
        .overlay(alignment: .bottom, content: {
            if sizeClass != .compact {
                iPadInstructionButton
            }
        })
        .sheet(isPresented: $showStepSheet) {
            stepDetailView
        }
        .fullScreenCover(isPresented: $showStepListSheet) {
            stepListView
        }
        .background(Color("backgroundColor")
            .ignoresSafeArea(.all, edges: .all))
        .navigationTitle(viewModel.currentGuide.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color("backgroundColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                stepListButton
            }
        }
        .navigationDestination(isPresented: $showConfirmationView) {
            ConfirmationView(
                viewModel: ConfirmationViewModel(
                    guideId: viewModel.currentGuide.id,
                    stepId: viewModel.currentStep?.id,
                    onStepConfirmation: {
                        Task {
                            await viewModel.onGetUpdatedGuideById {
                                showConfirmationView.toggle()
                            }
                        }
                        if !viewModel.isLastStep() {
                            viewModel.getNextStep()
                        }
                    },
                    isLastStep: viewModel.isLastStep()
                )
            )
            .onDisappear {
                if !showConfirmationView && !viewModel.isActuallyLastStep() && sizeClass == .compact {
                    showStepSheet.toggle()
                }
            }
        }
    }
}

private extension CollaborationView {
    @ViewBuilder
    var arViewContainer: some View {
    #if !targetEnvironment(simulator)
        VStack(spacing: 0) {
            ARViewContainer(
                // showStepSheet: $showStepSheet
            )
            .environmentObject(viewModel)
            .id(viewModel.uniqueID)
            .onAppear {
                viewModel.refreshCollaborationView()
            }
        }
    #endif
    }
    @ViewBuilder
    var infoLabel: some View {
        HStack {
            Text(L.Collaboration.info)
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(6)
        .padding()
    }
    var stepDetailView: some View {
        StepDetailView(
            viewModel: StepDetailViewModel(
                currentStep: viewModel.currentStep,
                onNavigateAction: {
                    showStepSheet.toggle()
                    showConfirmationView.toggle()
                },
                toggleStepDone: { viewModel.toggleStepDone($0) }
            )
        )
        .presentationDetents([.height(180), .large])
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled(sizeClass == .compact)
        .presentationDragIndicator(.visible)
    }
    var iPadInstructionButton: some View {
        Button(action: {
            showStepSheet.toggle()
        }) {
            VStack(alignment: .leading) {
                Text(L.StepDetail.instructions.uppercased())
                    .font(.system(size: 10).weight(.bold))
                    .foregroundColor(Color("disabledColor"))
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
                Text(viewModel.currentStep?.instruction?.text ?? L.Generic.unknown)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .font(.system(size: 16))
                    .foregroundColor(Color("disabledColor"))
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
            .background(Color("backgroundColor"))
            .frame(maxWidth: 500)
            .cornerRadius(8)
            .padding()
        }
    }
    var stepListView: some View {
        StepListView(
            viewModel: StepListViewModel(
                guide: viewModel.currentGuide,
                stepOrder: viewModel.currentStep?.order ?? 1,
                onSelectPreviousStep: { viewModel.getPreviousStep() }
            )
        )
        .onDisappear {
            if sizeClass == .compact {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showStepSheet.toggle()
                }
            }
        }
    }
    var stepListButton: some View {
        Button(action: {
            if sizeClass == .compact {
                showStepSheet.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showStepListSheet.toggle()
            }
        }) {
            Image(systemName: "text.badge.checkmark")
                .foregroundColor(.accentColor)
        }
    }
}

#Preview {
    CollaborationView(
        viewModel: CollaborationViewModel(
            currentGuide: ExtendedGuideResponse.example,
            referenceObjects: [],
            usdzModels: []
        )
    )
}
