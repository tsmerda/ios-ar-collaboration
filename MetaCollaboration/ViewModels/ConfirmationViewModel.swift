//
//  ConfirmationViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 01.11.2023.
//

import Foundation

final class ConfirmationViewModel: ObservableObject {
    let guide: ExtendedGuideResponse?
    let onStepConfirmation: () -> Void
    let isLastStep: Bool
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    
    init(
        guide: ExtendedGuideResponse?,
        onStepConfirmation: @escaping () -> Void,
        isLastStep: Bool = false
    ) {
        self.guide = guide
        self.onStepConfirmation = onStepConfirmation
        self.isLastStep = isLastStep
    }
    
    func onConfirmationAction() {
        // TODO: -- confirmation request implementation below
        // putGuideConfirmation()
        onStepConfirmation() // TODO: -- Remove after putGuideConfirmation request
    }
}

private extension ConfirmationViewModel {
//    func putGuideConfirmation() {
//        Task { @MainActor in
//            progressHudState = .shouldShowProgress
//            do {
//                try await NetworkManager.shared.putGuideConfirmation(guide: Guide)
//                progressHudState = .shouldShowSuccess(message: "Successfully confirmed")
//                onStepConfirmation()
//            } catch {
//                progressHudState = .shouldShowFail(message: error.localizedDescription)
//            }
//        }
//    }
}
