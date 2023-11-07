//
//  ProgressHUDHelper.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.10.2023.
//

import Foundation
import Combine
import ProgressHUD

enum ProgressHudHelper {
    static func dismiss(deadline: Double = 0.35) {
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
            ProgressHUD.dismiss()
        }
    }
}

enum ProgressHudState: Equatable {
    case shouldShowProgress
    case shouldShowSuccess(message: String? = nil)
    case shouldShowFail(message: String? = nil)
    case shouldHideProgress
}

final class ProgressHudBinding {
    private var subscriptions: Set<AnyCancellable> = []
    
    init(state: Published<ProgressHudState>.Publisher) {
        state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .shouldShowProgress: ProgressHUD.animate(interaction: false)
                case .shouldShowSuccess(let message): ProgressHUD.succeed(message)
                case .shouldShowFail(let message): ProgressHUD.failed(message)
                case .shouldHideProgress: ProgressHudHelper.dismiss()
                }
            }
            .store(in: &subscriptions)
    }
}
