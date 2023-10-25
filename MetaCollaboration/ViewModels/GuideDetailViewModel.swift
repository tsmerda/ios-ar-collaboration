//
//  GuideDetailViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.10.2023.
//

import Foundation

final class GuideDetailViewModel: ObservableObject {
    @Published var guide: Guide
    @Published var downloadedGuide: ExtendedGuideResponse?
    private let onGetGuide: () -> Void
    private let onSetCurrentGuide: () -> Void
    
    init(
        guide: Guide,
        downloadedGuide: ExtendedGuideResponse?,
        onGetGuide: @escaping () -> Void,
        onSetCurrentGuide: @escaping () -> Void
    ) {
        self.guide = guide
        self.downloadedGuide = downloadedGuide
        self.onGetGuide = onGetGuide
        self.onSetCurrentGuide = onSetCurrentGuide
    }
    
    func onGetGuideAction() {
        onGetGuide()
    }
    
    func onSetCurrentGuideAction() {
        onSetCurrentGuide()
    }
}
