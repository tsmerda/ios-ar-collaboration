//
//  SettingsViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.10.2023.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    private let removeAllFromLocalStorage: () -> Void
    
    init(removeAllFromLocalStorage: @escaping () -> Void) {
        self.removeAllFromLocalStorage = removeAllFromLocalStorage
    }
    
    func removeAllFromLocalStorageAction() {
        removeAllFromLocalStorage()
    }
}
