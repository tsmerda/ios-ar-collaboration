//
//  CollaborationView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI
import UIKit
import AVFoundation
import Vision
//import RealityKit
//import ARKit

class UIAVCollaborationViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var mlModel: VNCoreMLModel?
    var onARResultsChanged: ((String?) -> Void)?
    var ARResults: String?
    var recognitionInterval = 0 //Interval for object recognition
    
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
    
    // Detector
    private var videoOutput = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()
    var detectionLayer: CALayer! = nil
    
    @Binding var showingSheet: Bool
    
    init(showingSheet: Binding<Bool>) {
        _showingSheet = showingSheet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            
            self.setupLayers()
            self.setupDetector()
            
            self.captureSession.startRunning()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: -120, width: screenRect.size.width, height: screenRect.size.height)
        
        switch UIDevice.current.orientation {
            // Home button on top
        case UIDeviceOrientation.portraitUpsideDown:
            self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
            
            // Home button on right
        case UIDeviceOrientation.landscapeLeft:
            self.previewLayer.connection?.videoOrientation = .landscapeRight
            
            // Home button on left
        case UIDeviceOrientation.landscapeRight:
            self.previewLayer.connection?.videoOrientation = .landscapeLeft
            
            // Home button at bottom
        case UIDeviceOrientation.portrait:
            self.previewLayer.connection?.videoOrientation = .portrait
            
        default:
            break
        }
        
        // Detector
        updateLayers()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
        case .authorized:
            permissionGranted = true
            
            // Permission has not been requested yet
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    func setupCaptureSession() {
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        // Preview layer
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: -120, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        previewLayer.connection?.videoOrientation = .portrait
        
        // Detector
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
    
    // Function to handle tap gesture
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let boundingBoxView = gesture.view else { return }
        
        // Retrieve the recognized value from the associated object
        if let recognizedValue = objc_getAssociatedObject(boundingBoxView, UnsafeRawPointer(bitPattern: "recognizedValue".hashValue)!) as? String {
            print(recognizedValue)
            showingSheet = true
        }
    }
}

struct CollaborationView: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: CollaborationViewModel
    @Binding var showingSheet: Bool
    
    func makeUIViewController(context: Context) -> UIAVCollaborationViewController {
        let uiView = UIAVCollaborationViewController(showingSheet: $showingSheet)
        
        if (viewModel.mlModel != nil) {
            uiView.mlModel = viewModel.mlModel
        }
        
        uiView.ARResults = viewModel.ARResults
        
        uiView.onARResultsChanged = { result in
            DispatchQueue.main.async {
                viewModel.ARResults = result ?? ""
            }
        }
        
        uiView.showingSheet = showingSheet
        
        //        uiView.setupSession()
        //        uiView.setupPreview()
        return uiView
    }
    
    func updateUIViewController(_ uiViewController: UIAVCollaborationViewController, context: Context) {
        uiViewController.mlModel = viewModel.mlModel
        uiViewController.showingSheet = showingSheet
    }
    
    typealias UIViewType = UIAVCollaborationViewController
}
