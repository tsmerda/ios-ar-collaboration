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
            // TODO: -- fix ipad layout
            if sizeClass != .compact {
                VStack {
                    Spacer()
                    bottomStackViewForIpad
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
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
                if !showConfirmationView && sizeClass == .compact && !viewModel.isActuallyLastStep() {
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
                //                showStepSheet: $showStepSheet
            )
            .environmentObject(viewModel)
            // .zIndex(1)
            // .id(viewModel.uniqueID)
            // .onAppear {
            //   viewModel.refreshCollaborationView()
            // }
        }
        #endif
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
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .interactiveDismissDisabled()
        .presentationDragIndicator(.automatic)
    }
    // TODO: -- Fix this view initialization for tablet? (use sheet?)
    var bottomStackViewForIpad: some View {
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
        //        .frame(maxWidth: .infinity, maxHeight: 400)
        //        .cornerRadius(8)
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
            showStepSheet.toggle()
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
