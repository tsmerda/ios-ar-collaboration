//
//  UIAVCollaborationViewController+HandleDetection.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 24.05.2023.
//

import SwiftUI
import UIKit
import AVFoundation
import Vision
import RealityKit
import ARKit

extension UIAVCollaborationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if isRecognizing {
            return
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        objectsLayer.removeFromSuperlayer()
        isRecognizing = true
        
        objectRecognizer.recognize(fromPixelBuffer: pixelBuffer) { [weak self] objects in
            DispatchQueue.main.async {
                self?.drawRecognizedObjects(objects)
                self?.isRecognizing = false
            }
        }
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: cameraView)
        
        // Find the tapped object
        guard let tappedObject = objectsLayer.sublayers?.compactMap({ $0 as? CALayer }).first(where: { $0.frame.contains(tapLocation) }) else {
            return
        }
        
        // Get the text from the tapped object's text layer
        guard let textLayer = tappedObject.sublayers?.compactMap({ $0 as? CATextLayer }).first,
              let tappedText = textLayer.string as? NSAttributedString else {
            return
        }
        
        // Update showingSheet and ARResults
        // Send result to View Model, execute it in the main thread
        DispatchQueue.main.async {
            self.onARResultsChanged?(tappedText.string)
        }
        print("Tappded: \(tappedText.string)")
        showingSheet = true
    }
    
}
