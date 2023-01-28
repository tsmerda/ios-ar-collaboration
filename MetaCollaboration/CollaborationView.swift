//
//  CollaborationView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI
import AVFoundation
import Vision
import RealityKit
import ARKit

class UIAVCollaborationView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    // AVCaptureVideoDataOutputSampleBufferDelegate
    // when you want to handle the video input every second, you will add the delegate
    var recognitionInterval = 0 //Interval for object recognition
    
    var mlModel: VNCoreMLModel?
    
    var captureSession: AVCaptureSession!
    
    var onARResultsChanged: ((String?) -> Void)?
    
    var ARResults: String?
    
    var resultLabel: UILabel!
    
    func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        guard captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
        
        // Output settings
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue")) // set delegate to receive the data every frame
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        captureSession.commitConfiguration()
    }
    
    func setupPreview() {
        //    TODO: -- Fix available frame
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 240)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.frame = self.frame
        
        self.layer.addSublayer(previewLayer)
        
        resultLabel = UILabel()
        resultLabel.text = ARResults
        resultLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 240, width: UIScreen.main.bounds.width, height: 80)
        resultLabel.textColor = UIColor.black
        resultLabel.textAlignment = NSTextAlignment.center
        resultLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        resultLabel.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)
        
        self.addSubview(resultLabel)
        
        self.captureSession.startRunning()
    }
    
    // captureOutput will be called for each frame was written
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Recognise the object every 20 frames
        if recognitionInterval < 20 {
            recognitionInterval += 1
            return
        }
        recognitionInterval = 0
        
        // Convert CMSampleBuffer(an object holding media data) to CMSampleBufferGetImageBuffer
        guard
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let model = mlModel // Unwrap the mlModel
        else { return }
        
        // Create image process request, pass model and result
        let request = VNCoreMLRequest(model: model) { //An image analysis request that uses a Core ML model to process images.
            
            (request: VNRequest, error: Error?) in
            
            // Get results as VNClassificationObservation array
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            // top 5 results
            self.ARResults = ""
            for result in results.prefix(5) {
                self.ARResults! += "\(Int(result.confidence * 100))%" + result.identifier + "\n"
            }
            
            // Execute it in the main thread
            DispatchQueue.main.async {
                self.onARResultsChanged?(self.ARResults)
                self.resultLabel.text = self.ARResults
            }
        }
        
        // Execute the request
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

struct CollaborationView: UIViewRepresentable {
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    let uiView = UIAVCollaborationView()
    
    func makeUIView(context: Context) -> UIAVCollaborationView {
        if (viewModel.mlModel != nil) {
            print("=== Set model ===")
            uiView.mlModel = viewModel.mlModel
        } else {
            print("=== Nothing selected ===")
            // Show that nothing is selected
        }
        
        uiView.ARResults = viewModel.ARResults
        
        uiView.onARResultsChanged = { result in
            DispatchQueue.main.async {
                viewModel.ARResults = result ?? ""
            }
        }
        
        uiView.setupSession()
        uiView.setupPreview()
        return uiView
    }
    
    func updateUIView(_ uiView: UIAVCollaborationView, context: Context) {
        uiView.mlModel = viewModel.mlModel
    }
    
    typealias UIViewType = UIAVCollaborationView
}

//struct CollaborationView_Previews: PreviewProvider {
//    static var previews: some View {
//        CollaborationView()
//    }
//}
