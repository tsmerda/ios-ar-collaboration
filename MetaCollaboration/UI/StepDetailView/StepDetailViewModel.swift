//
//  StepDetailViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 29.10.2023.
//

import Foundation

final class StepDetailViewModel: ObservableObject {
    @Published var currentStep: ObjectStep?
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    
    let onNavigateAction: () -> Void
    let toggleStepDone: (Step) -> Void
    
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
    
    func onToggleStepDoneAction(_ step: Step) {
        // TODO: - Add network call to update step confirmation
        guard let stepsIndex = currentStep?.steps?.firstIndex(where: { $0.id == step.id }) else { return }
        let isDone = currentStep?.steps?[stepsIndex].confirmation?.done ?? false
        currentStep?.steps?[stepsIndex].confirmation?.done = !isDone
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
