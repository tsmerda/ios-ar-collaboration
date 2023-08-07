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
    
    @State private var showStepSheet = true
    @State private var showConfirmationView = false
    
    // TODO: - Pridat haptic feedback let hapticFeedback = UINotificationFeedbackGenerator()
    var body: some View {
        NavigationStack() {
            GeometryReader { geo in
                VStack(spacing: 0) {
//                    ARViewContainer(showStepSheet: $showStepSheet)
//                        .environmentObject(viewModel)
//                        .zIndex(1)
//                    //                        .id(viewModel.uniqueID)
//                        .onAppear {
//                            viewModel.refreshCollaborationView()
//                        }
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
                            // TODO: - Zobrazit alert nez zavre guide?
                            collaborationMode = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: StepListView(guide: viewModel.currentGuide!)
                            .onAppear{
                                showStepSheet.toggle()
                            }
                            .onDisappear {
                                showStepSheet.toggle()
                            })
                        {
                            Image(systemName: "text.badge.checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showConfirmationView) {
                ConfirmationView(guide: viewModel.currentGuide!)
                    .onDisappear {
                        showStepSheet.toggle()
                    }
            }
        }
    }
}

@available(iOS 16.4, *)
struct CollaborationView_Previews: PreviewProvider {
    static var previews: some View {
        CollaborationView().environmentObject(CollaborationViewModel())
    }
}
