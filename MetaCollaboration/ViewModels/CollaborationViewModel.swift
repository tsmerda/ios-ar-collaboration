//
//  CollaborationViewModel.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit

import ARKit
import SwiftUI
import RealityKit
import MultipeerConnectivity


enum ActiveAppMode: String {
    case none
    case onlineMode
    case offlineMode
}

final class CollaborationViewModel: ObservableObject {
    // MARK: - Properties
    // TODO: - je @Published potreba?
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    @Published var referenceObjects: Set<ARReferenceObject> = []
    @Published var currentStep: ObjectStep? /*= ObjectStep.example*/
    @Published var currentGuide: ExtendedGuideResponse
    //    @Published var uniqueID = UUID()
    
    // MARK: Collaboration properties
    
    @Published var arView: ARView!
    @Published var multipeerSession: MultipeerSession?
    @Published var sessionIDObservation: NSKeyValueObservation?
    
    // TODO: - je tohle potreba?
    var showStepSheet: Binding<Bool>?
    
    // A dictionary to map MultiPeer IDs to ARSession ID's.
    // This is useful for keeping track of which peer created which ARAnchors.
    var peerSessionIDs = [MCPeerID: String]()
    
    // MARK: - Initialization
    init(
        currentGuide: ExtendedGuideResponse,
        referenceObjects: Set<ARReferenceObject>
    ) {
        self.currentGuide = currentGuide
        self.referenceObjects = referenceObjects
        debugPrint(referenceObjects)
        if let currentGuideId = currentGuide.id,
           let firstStepOrder = currentGuide.objectSteps?.first?.order {
            getStepById(currentGuideId, firstStepOrder)
        } else {
            debugPrint("Failed to get first step")
        }
    }
    
    deinit {
        debugPrint("CollaborationView DEINIT")
    }
    
    // MARK: - Public Methods
    //    func refreshCollaborationView() {
    // TODO: - Opravit nastaveni UUID() -> zpusobovalo seknuti pri prejiti na ARView
    //        self.uniqueID = UUID()
    //    }
    
    func toggleStepDone(step: Step) {
        //        if let index = currentStep?.steps?.firstIndex(where: { $0.id == step.id }) {
        //            currentStep?.steps?[index].confirmation?.done.toggle()
        //        }
    }
    
    func getNextStep() {
        if let currentGuideId = currentGuide.id,
           let currentStepOrder = currentStep?.order {
            getStepById(currentGuideId, currentStepOrder + 1)
        } else {
            debugPrint("Failed to get next step")
        }
    }
    
    func getPreviousStep() {
        if let currentGuideId = currentGuide.id,
           let currentStepOrder = currentStep?.order {
            getStepById(currentGuideId, currentStepOrder - 1)
        } else {
            debugPrint("Failed to get previous step")
        }
    }
    
    func isLastStep() -> Bool {
        if let currentStepOrder = currentStep?.order,
           let stepCount = currentGuide.objectSteps?.count {
            return currentStepOrder == Decimal(stepCount)
        } else {
            return false
        }
    }
}

// MARK: - Network methods

extension CollaborationViewModel {
    func getStepById(_ guideId: String, _ objectStepOrder: Decimal) {
        Task { @MainActor in
            progressHudState = .shouldShowProgress
            do {
                currentStep = try await NetworkManager.shared.getStepById(guideId: guideId, objectStepOrder: objectStepOrder)
                progressHudState = .shouldHideProgress
            } catch {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
}
