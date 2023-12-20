//
//  StepDetailViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 29.10.2023.
//

import Foundation

final class StepDetailViewModel: ObservableObject {
    let currentStep: ObjectStep?
    let onNavigateAction: () -> Void
    let toggleStepDone: (Step) -> Void
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    
    init(
        currentStep: ObjectStep?,
        onNavigateAction: @escaping () -> Void,
        toggleStepDone: @escaping (Step) -> Void
    ) {
        self.currentStep = currentStep
        self.onNavigateAction = onNavigateAction
        self.toggleStepDone = toggleStepDone
    }
    
    func onConfirmationAction() {
        onStepConfirmation()
    }
}

private extension StepDetailViewModel {
    func onStepConfirmation() {
//        Task { @MainActor in
//            progressHudState = .shouldShowProgress
//            guard let guideId = guideId, let stepId = stepId else {
//                progressHudState = .shouldShowFail(message: "Missing guide ID or step ID.")
//                return
//            }
//            
//            do {
//                try await NetworkManager.shared.putObjectStepConfirmation(
//                    confirmation: Confirmation(
//                        comment: "",
//                        photoUrl: "",
//                        date: Int64(Date().timeIntervalSince1970),
//                        done: true
//                    ),
//                    guideId: guideId,
//                    objectStepId: stepId
//                )
//                onStepConfirmation()
//                progressHudState = .shouldShowSuccess(message: "Successfully confirmed")
//            } catch {
//                progressHudState = .shouldShowFail(message: error.localizedDescription)
//            }
//        }
    }
}
