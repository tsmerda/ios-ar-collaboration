//
//  StepListViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 29.10.2023.
//

import Foundation

final class StepListViewModel: ObservableObject {
    let guide: ExtendedGuideResponse?
    let currentStepId: String
    let onSelectStep: (Int) -> Void
    
    init(
        guide: ExtendedGuideResponse?,
        currentStepId: String,
        onSelectStep: @escaping (Int) -> Void
    ) {
        self.guide = guide
        self.currentStepId = currentStepId
        self.onSelectStep = onSelectStep
    }
}
