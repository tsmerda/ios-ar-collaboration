//
//  ConfirmationViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 01.11.2023.
//

import Foundation

final class ConfirmationViewModel: ObservableObject {
    let guideId: String?
    let stepId: String?
    let onStepConfirmation: () -> Void
    let isLastStep: Bool
    
    @Published var selectedRating: Int = 0
    @Published var comment: String = ""
    @Published var photoUrl: String = ""
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    
    init(
        guideId: String?,
        stepId: String?,
        onStepConfirmation: @escaping () -> Void,
        isLastStep: Bool = false
    ) {
        self.guideId = guideId
        self.stepId = stepId
        self.onStepConfirmation = onStepConfirmation
        self.isLastStep = isLastStep
    }
    
    func onConfirmationAction() async {
        await onObjectStepConfirmation()
    }
}

private extension ConfirmationViewModel {
    func onObjectStepConfirmation() async {
        await MainActor.run {
            progressHudState = .shouldShowProgress
        }
        guard let guideId = guideId, let stepId = stepId else {
            await MainActor.run {
                progressHudState = .shouldShowFail(message: L.Confirmation.missingIDs)
            }
            return
        }
        var finalComment = comment
        if selectedRating != 0 {
            if !finalComment.isEmpty {
                finalComment += ". "
            }
            finalComment += "\(L.Confirmation.rating) \(selectedRating) \(selectedRating.ratingDescription)."
        }
        do {
            try await NetworkManager.shared.putObjectStepConfirmation(
                confirmation: Confirmation(
                    comment: finalComment,
                    photoUrl: "",
                    date: Int64(Date().timeIntervalSince1970),
                    done: true
                ),
                guideId: guideId,
                objectStepId: stepId
            )
            await MainActor.run {
                onStepConfirmation()
                progressHudState = .shouldShowSuccess(message: L.Confirmation.confirmed)
            }
        } catch {
            await MainActor.run {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
}
