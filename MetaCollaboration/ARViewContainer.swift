//
//  ARViewContainer.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 28.01.2023.
//

import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewControllerRepresentable {
  func makeUIViewController(
    context _: UIViewControllerRepresentableContext<
    ARViewContainer
    >
  ) -> RealityViewController {
    RealityViewController()
  }

  func updateUIViewController(
    _: RealityViewController,
    context _: UIViewControllerRepresentableContext<
    ARViewContainer
    >
  ) {}
}
