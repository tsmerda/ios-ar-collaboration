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

final class CollaborationViewModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var progressHudState: ProgressHudState = .shouldHideProgress
    @Published var referenceObjects: Set<ARReferenceObject> = []
    @Published var usdzModels: Set<URL> = []
    @Published var currentStep: ObjectStep?
    @Published var currentGuide: ExtendedGuideResponse
    @Published private(set) var currentStepNumber: Int = 0
    @Published var uniqueID = UUID()
    
    // MARK: Collaboration properties
    
    @Published var arView: ARView!
    @Published var multipeerSession: MultipeerSession?
    @Published var sessionIDObservation: NSKeyValueObservation?
    
    private var isFirstLoad = true
    
    // TODO: - Check if this variable is necessary
    var showStepSheet: Binding<Bool>?
    
    // A dictionary to map MultiPeer IDs to ARSession ID's.
    // This is useful for keeping track of which peer created which ARAnchors.
    var peerSessionIDs = [MCPeerID: String]()
        
    // MARK: - Initialization
    init(
        currentGuide: ExtendedGuideResponse,
        referenceObjects: Set<ARReferenceObject>,
        usdzModels: Set<URL>
    ) {
        self.currentGuide = currentGuide
        self.referenceObjects = referenceObjects
        self.usdzModels = usdzModels
        
        if let currentGuideId = currentGuide.id,
           let firstStepOrder = currentGuide.objectSteps?.first?.order {
            getStepById(currentGuideId, firstStepOrder)
        } else {
            debugPrint("Failed to get first step")
        }
    }
    
    deinit {
        // debugPrint("CollaborationView DEINIT")
    }
    
    // MARK: - Public Methods
    func refreshCollaborationView() {
        // Without this implementation, it caused a crash when switching to ARView
        self.uniqueID = UUID()
    }
    
    func toggleStepDone(_ step: Step) {
        ///        if let index = currentStep?.steps?.firstIndex(where: { $0.id == step.id }) {
        ///            currentStep?.steps?[index].confirmation?.done.toggle()
        ///        }
    }
    
    func getNextStep() {
        if let currentGuideId = currentGuide.id,
           let currentStepOrder = currentStep?.order {
            getStepById(currentGuideId, currentStepOrder + 1)
            currentStepNumber += 1
        } else {
            debugPrint("Failed to get next step")
        }
    }
    
    func getPreviousStep() {
        if let currentGuideId = currentGuide.id,
           let currentStepOrder = currentStep?.order {
            getStepById(currentGuideId, currentStepOrder - 1)
            currentStepNumber -= 1
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
    
    func isActuallyLastStep() -> Bool {
        let totalSteps = currentGuide.objectSteps?.count ?? 0
        return currentStepNumber >= totalSteps
    }
    
    func getUSDZModelForCurrentStep() -> URL? {
        guard let objectName = currentStep?.objectName else { return nil }
        return usdzModels.first { $0.lastPathComponent == objectName }
    }
}

// MARK: - Network methods

extension CollaborationViewModel {
    // Get step by ID
    func getStepById(_ guideId: String, _ objectStepOrder: Decimal) {
        Task { @MainActor in
            progressHudState = .shouldShowProgress
            do {
                let currentStepResponse = try await NetworkManager.shared.getStepById(guideId: guideId, objectStepOrder: objectStepOrder)
                currentStep = currentStepResponse
                if !isFirstLoad {
                    replaceUSDZModel()
                }
                isFirstLoad = false
                progressHudState = .shouldHideProgress
            } catch {
                progressHudState = .shouldShowFail(message: error.localizedDescription)
            }
        }
    }
    
    func onGetUpdatedGuideById(completion: @escaping () -> Void) async {
        if isLastStep() {
            currentStepNumber += 1
        }
        await getUpdatedGuideById()
        completion()
    }
    
    // Get updated guide by ID
    func getUpdatedGuideById() async {
        if let currentGuideId = currentGuide.id {
            await MainActor.run {
                progressHudState = .shouldShowProgress
            }
            do {
                let updatedGuide = try await NetworkManager.shared.getGuideById(guideId: currentGuideId)
                await MainActor.run {
                    currentGuide = updatedGuide
                }
                try PersistenceManager.shared.updateGuide(updatedGuide)
                await MainActor.run {
                    progressHudState = .shouldHideProgress
                }
            } catch {
                await MainActor.run {
                    progressHudState = .shouldShowFail(message: error.localizedDescription)
                }
            }
        }
    }
}
