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
    //    @State private var showImagePopup = false
    
    private let progressHudBinding: ProgressHudBinding
    
    init(viewModel: CollaborationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        ZStack {
            arViewContainer
        }
        .sheet(isPresented: $showStepSheet) {
            stepDetailView
        }
        .fullScreenCover(isPresented: $showStepListSheet) {
            stepListView
        }
        .background(Color("backgroundColor")
            .ignoresSafeArea(.all, edges: .all))
        .navigationTitle(viewModel.currentGuide?.name ?? "Upgrading old Prusa MK2s.")
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
            ConfirmationView(guide: viewModel.currentGuide ?? nil)
                .onDisappear {
                    showStepSheet.toggle()
                }
        }
    }
}

private extension CollaborationView {
    @ViewBuilder
    var arViewContainer: some View {
        #if !targetEnvironment(simulator)
        VStack(spacing: 0) {
            //            ARViewContainer(showStepSheet: $showStepSheet)
            //                .environmentObject(viewModel)
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
                toggleStepDone: { viewModel.toggleStepDone(step: $0) }
            )
        )
        .presentationDetents([.height(180), .medium])
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        .interactiveDismissDisabled()
        .presentationDragIndicator(.automatic)
    }
    var stepListView: some View {
        StepListView(
            viewModel: StepListViewModel(
                guide: viewModel.currentGuide ?? nil,
                currentStepId: viewModel.currentStep?.id ?? "",
                onSelectStep: {
                    viewModel.getStepById(viewModel.currentGuide?.id ?? "", $0)
                }
            )
        )
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showStepSheet.toggle()
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
            referenceObjects: []
        )
    )
}

//                    VStack {
//                        Spacer()
//                        HStack {
//                            Spacer()
//
//                            if viewModel.currentGuide?.imageUrl != nil {
//                                AsyncImage(url: URL(string: (viewModel.currentGuide?.imageUrl)!)){ image in
//                                    image
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                } placeholder: { Color("secondaryColor") }
//                                    .frame(width: 80, height: 80)
//                                    .cornerRadius(8)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 11)
//                                            .stroke(Color.accentColor, lineWidth: 1)
//                                    )
//                                    .padding()
//                                    .padding(.bottom, 160)
//                                    .onTapGesture {
//                                        showImagePopup.toggle()
//                                    }
//                            }
//                        }
//                    }

//                    if showImagePopup {
//                        ImagePopupView(showImagePopup: $showImagePopup, imageUrl: viewModel.currentGuide?.imageUrl ?? "")
//                    }
