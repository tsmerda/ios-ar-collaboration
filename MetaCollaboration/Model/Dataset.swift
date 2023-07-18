//
//  Dataset.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 12.03.2023.
//

import Foundation



struct Dataset: Identifiable, Equatable, Hashable {
    let id = UUID()
    var title: String
    var desc: String
    var image: String
    var info: String
    var url: String
}


// MARK: - Mock data for testing

var MockDatasetList: [Dataset] = [
    Dataset(title: "SqueezeNet", desc: "Image Classification", image: "squeeze-net", info: "A small Deep Neural Network architecture that classifies the dominant object in a camera frame or image.", url: "https://ml-assets.apple.com/coreml/models/Image/ImageClassification/SqueezeNet/SqueezeNet.mlmodel"),
    Dataset(title: "Resnet50", desc: "Image Classification", image: "resnet-50", info: "A Residual Neural Network that will classify the dominant object in a camera frame or image.", url: "https://ml-assets.apple.com/coreml/models/Image/ImageClassification/Resnet50/Resnet50.mlmodel")
]
