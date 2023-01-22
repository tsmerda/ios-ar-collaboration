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

class CollaborationViewModel: ObservableObject {
    @Published var mlModel: VNCoreMLModel?
    @Published var isLoading = false
    @Published var selectedDataset: String = ""
    @Published var datasetList: [Dataset] = [
        Dataset(title: "SqueezeNet", desc: "Lorem ipsum", url: "https://ml-assets.apple.com/coreml/models/Image/ImageClassification/SqueezeNet/SqueezeNet.mlmodel"),
        Dataset(title: "Resnet50", desc: "Lorem ipsum", url: "https://ml-assets.apple.com/coreml/models/Image/ImageClassification/Resnet50/Resnet50.mlmodel")
    ]
    
    // Download selected Dataset
    func download(_ modelUrl: String) {
        print("Downloading start")
        isLoading = true
        
        let url = URL(string: modelUrl)!
        let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let savedURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if FileManager.default.fileExists(atPath: savedURL.path) {
                // model is already downloaded
                print("Is already downloaded")
                do {
                    let compiledUrl = try MLModel.compileModel(at: savedURL)
                    let result = Result {
                        try VNCoreMLModel(for: MLModel(contentsOf: compiledUrl))
                        
                    }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let model):
                            self.mlModel = model
                        case .failure(let error):
                            print(error)
                        }
                    }
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    self.selectedDataset = url.lastPathComponent
                    self.isLoading = false
                    print("Already downloaded end")
                }
            } else {
                // model is not downloaded, download it
                URLSession.shared.downloadTask(with: url) { (location, _, _) in
                    guard let location = location else { return }
                    do {
                        // Move the file to the documents directory
                        try FileManager.default.moveItem(at: location, to: savedURL)
                        // Compile the model
                        let compiledUrl = try MLModel.compileModel(at: savedURL)
                        self.mlModel = try VNCoreMLModel(for: MLModel(contentsOf: compiledUrl))
                    } catch {
                        print(error)
                    }
                    DispatchQueue.main.async {
                        self.selectedDataset = url.lastPathComponent
                        self.isLoading = false
                        print("Downloading end")
                    }
                }.resume()
            }
        }
    }
}

struct Dataset: Identifiable, Equatable, Hashable {
    let id = UUID()
    var title: String
    var desc: String
    var url: String
}
