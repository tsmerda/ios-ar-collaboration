//
//  CollaborationView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct CollaborationView: View {
    @AppStorage("collaborationMode") var collaborationMode: Bool = false
    
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    @State private var showStepSheet = false
    @State private var showStepListSheet = false
    @State private var showConfirmationView = false
    //    @State private var showImagePopup = false
    
    var body: some View {
        NavigationStack() {
            GeometryReader { geo in
                ZStack {
                    VStack(spacing: 0) {
                    #if !targetEnvironment(simulator)
                        ARViewContainer(showStepSheet: $showStepSheet)
                            .environmentObject(viewModel)
                        // .zIndex(1)
                        // .id(viewModel.uniqueID)
                            .onAppear {
                                viewModel.refreshCollaborationView()
                            }
                    #endif
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showStepListSheet = true
                    }
                }
                .sheet(isPresented: $showStepSheet) {
                    StepDetailView(onNavigateAction: {
                        showStepSheet.toggle()
                        showConfirmationView.toggle()
                    })
                    .environmentObject(viewModel)
                    .presentationDetents([.height(160), .medium])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .interactiveDismissDisabled()
                    .presentationDragIndicator(.automatic)
                }
                .fullScreenCover(isPresented: $showStepListSheet) {
                    StepListView(
                        guide: viewModel.currentGuide ?? nil,
                        currentStepId: viewModel.currentStep?.id ?? "",
                        onSelectStep: { viewModel.getStepById(viewModel.currentGuide?.id ?? "", $0) }
                    )
                    .onDisappear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showStepSheet.toggle()
                        }
                    }
                }
                .background(Color("backgroundColor")
                    .ignoresSafeArea(.all, edges: .all))
                .navigationTitle(viewModel.currentGuide?.name ?? "Upgrading old Prusa MK2s.")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Color("backgroundColor"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
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
            }
            .navigationDestination(isPresented: $showConfirmationView) {
                ConfirmationView(guide: viewModel.currentGuide ?? nil)
                    .onDisappear {
                        showStepSheet.toggle()
                    }
            }
        }
    }
}

struct CollaborationView_Previews: PreviewProvider {
    static var previews: some View {
        CollaborationView().environmentObject(CollaborationViewModel())
    }
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
