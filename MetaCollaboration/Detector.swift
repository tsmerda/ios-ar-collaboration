//
//  Detector.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 01.05.2023.
//

import Vision
import AVFoundation
import UIKit

extension UIAVCollaborationViewController {
    
    func setupDetector() {
        let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc")
        
        do {
            let visionModel: VNCoreMLModel
            if mlModel == nil {
                visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL!))
            } else {
                visionModel = mlModel!
            }
            let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
            self.requests = [recognitions]
        } catch let error {
            print(error)
        }
    }
    
    func detectionDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: {
            if let results = request.results {
                self.extractDetections(results)
            }
        })
    }

    func extractDetections(_ results: [VNObservation]) {
        detectionLayer.sublayers = nil

        for observation in results where observation is VNRecognizedObjectObservation {
            print(observation)
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }

            // Transformations
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
            let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)

            // Text annotation
            /// Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let textLayer = self.createTextSubLayerInBounds(transformedBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)

            // Send result to View Model, execute it in the main thread
            DispatchQueue.main.async {
                self.onARResultsChanged?(String(format: "\(topLabelObservation.identifier)\nConfidence:  %.2f", topLabelObservation.confidence))
            }

            let boxLayer = self.drawBoundingBox(transformedBounds, String(format: "\(topLabelObservation.identifier)\nConfidence:  %.2f", topLabelObservation.confidence))

            boxLayer.addSublayer(textLayer)
            detectionLayer.addSublayer(boxLayer)
        }
    }
    
    func setupLayers() {
        detectionLayer = CALayer()
        detectionLayer.frame = CGRect(x: 0, y: -120, width: screenRect.size.width, height: screenRect.size.height)
        self.view.layer.addSublayer(detectionLayer)
    }
    
    func updateLayers() {
        //        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        guard let sublayers = self.detectionLayer?.sublayers else { return }
        
        let transform = CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -screenRect.width, y: -screenRect.height)
        let overlayLayer = CALayer()
        overlayLayer.frame = screenRect
        
        for layer in sublayers {
            if let objectObservationLayer = layer as? CATextLayer {
                var objectBounds = objectObservationLayer.frame
                objectBounds = objectBounds.applying(transform)
                objectObservationLayer.frame = objectBounds
                overlayLayer.addSublayer(objectObservationLayer)
            } else if let objectObservationLayer = layer as? CAShapeLayer {
                var objectBounds = objectObservationLayer.frame
                objectBounds = objectBounds.applying(transform)
                objectObservationLayer.frame = objectBounds
                overlayLayer.addSublayer(objectObservationLayer)
            }
        }
        
        self.detectionLayer?.addSublayer(overlayLayer)
    }
    
    func drawBoundingBox(_ bounds: CGRect, _ recognizedValue: String) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.name = "Object Frame"
        boxLayer.bounds = bounds
        boxLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        boxLayer.borderWidth = 1.0
        boxLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        boxLayer.borderColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        boxLayer.cornerRadius = 4
        boxLayer.zPosition = 100
        
        // Create a UIView and set it as the contents of the layer
        let boundingBoxView = UIView(frame: bounds)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        
        // Pass the recognized value as an associated object
        objc_setAssociatedObject(boundingBoxView, UnsafeRawPointer(bitPattern: "recognizedValue".hashValue)!, recognizedValue, .OBJC_ASSOCIATION_RETAIN)
        
        boundingBoxView.addGestureRecognizer(tapGesture)
        boundingBoxView.isUserInteractionEnabled = true
        boxLayer.contents = boundingBoxView.layer
        self.view.addSubview(boundingBoxView)
        
        return boxLayer
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height + 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        //        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:]) // Create handler to perform request on the buffer
        do {
            try imageRequestHandler.perform(self.requests) // Schedules vision requests to be performed
        } catch {
            print(error)
        }
    }
}
