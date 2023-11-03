//
//  StepListViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 29.10.2023.
//

import Foundation

final class StepListViewModel: ObservableObject {
    let guide: ExtendedGuideResponse?
    let stepOrder: Decimal?
    let onSelectPreviousStep: () -> Void
    
    init(
        guide: ExtendedGuideResponse?,
        stepOrder: Decimal,
        onSelectPreviousStep: @escaping () -> Void
    ) {
        self.guide = guide
        self.stepOrder = stepOrder
        self.onSelectPreviousStep = onSelectPreviousStep
    }
}
