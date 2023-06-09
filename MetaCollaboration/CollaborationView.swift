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
import ARKit

class UIAVCollaborationViewController: UIViewController {
    @Binding var showingSheet: Bool
    var mlModel: VNCoreMLModel?
    var onARResultsChanged: ((String?) -> Void)?
    var ARResults: String?
    var objectRecognizer = ObjectRecognizer()
    
    var cameraView: UIView
    var isRecognizing = false
    var objectsLayer: CALayer = CALayer()
    
    required init(showingSheet: Binding<Bool>) {
        _showingSheet = showingSheet
        self.cameraView = UIView()
        self.queue = DispatchQueue(label: "LiveCameraViewController")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objectRecognizer = ObjectRecognizer(mlModel: mlModel)
        cameraView.frame = CGRect(x:0,
                                  y:0,
                                  width:view.frame.size.width,
                                  height: view.frame.size.height / 2)
        cameraView.frame = self.view.frame
        view.addSubview(cameraView)
        
        configureSession()
        configurePreview()
        session?.startRunning()
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        cameraView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillLayoutSubviews() {
        cameraView.frame = view.frame
        previewLayer?.frame = cameraView.layer.bounds
        previewLayer?.connection?.videoOrientation = OrientationUtils.videoOrientationForCurrentOrientation()
    }
    
    // MARK: - Private
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var queue: DispatchQueue
    private var session: AVCaptureSession?
    private var videoSize: CGSize = .zero
    
    /// Configure the preview layer
    /// the layer is added to the cameraView
    private func configurePreview() {
        guard let session = session else {return}
        if self.previewLayer == nil {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = cameraView.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
        }
    }
    
    private func configureSession() {
        let session = AVCaptureSession()
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera, .builtInTelephotoCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: .unspecified)
        
        guard let captureDevice = deviceDiscoverySession.devices.first,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
              session.canAddInput(videoDeviceInput)
        else { return }
        session.addInput(videoDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        session.addOutput(videoOutput)
        session.sessionPreset = .vga640x480
        
        let captureConnection = videoOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        
        let dimensions  = CMVideoFormatDescriptionGetDimensions((captureDevice.activeFormat.formatDescription))
        videoSize.width = CGFloat(dimensions.width)
        videoSize.height = CGFloat(dimensions.height)
        
        self.session = session
    }
    
    func drawRecognizedObjects(_ objects:[RecognizedObject]) {
        guard let previewLayer = previewLayer else { return }
        
        objectsLayer = GeometryUtils.createLayer(forRecognizedObjects: objects,
                                                 inFrame: previewLayer.frame)
        
        previewLayer.addSublayer(objectsLayer)
        previewLayer.setNeedsDisplay()
    }
    
}


struct CollaborationView: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: CollaborationViewModel
    @Binding var showingSheet: Bool
    
    func makeUIViewController(context: Context) -> UIAVCollaborationViewController {
        let uiView = UIAVCollaborationViewController(showingSheet: $showingSheet)
        
        if viewModel.mlModel != nil {
            uiView.mlModel = viewModel.mlModel
            uiView.objectRecognizer = ObjectRecognizer(mlModel: viewModel.mlModel)
        }
        
        uiView.ARResults = viewModel.ARResults
        uiView.onARResultsChanged = { result in
            DispatchQueue.main.async {
                viewModel.ARResults = result ?? ""
            }
        }
        
        uiView.showingSheet = showingSheet
        
        return uiView
    }
    
    func updateUIViewController(_ uiViewController: UIAVCollaborationViewController, context: Context) {
        uiViewController.mlModel = viewModel.mlModel
        uiViewController.showingSheet = showingSheet
    }
    
    typealias UIViewType = UIAVCollaborationViewController
}
