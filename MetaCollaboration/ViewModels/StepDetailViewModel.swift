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
    
    init(
        currentStep: ObjectStep?,
        onNavigateAction: @escaping () -> Void,
        toggleStepDone: @escaping (Step) -> Void
    ) {
        self.currentStep = currentStep
        self.onNavigateAction = onNavigateAction
        self.toggleStepDone = toggleStepDone
    }
}
