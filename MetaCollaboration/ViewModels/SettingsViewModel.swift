//
//  SettingsViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.10.2023.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    private let removeAllFromLocalStorage: () -> Void
    @Published var downloadedAssets: [String] = []
    
    init(
        removeAllFromLocalStorage: @escaping () -> Void,
        downloadedAssets: [String]
    ) {
        self.removeAllFromLocalStorage = removeAllFromLocalStorage
        self.downloadedAssets = downloadedAssets
    }
    
    func removeAllFromLocalStorageAction() {
        removeAllFromLocalStorage()
    }
}
