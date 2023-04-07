//
//  DatasetListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI
import CoreML
import Vision

struct DatasetListView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    @State private var showingSheet = false
    @State private var selectedAsset: Asset?
    @State private var selectedGuide: Guide?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("USDZ models")) {
                    ForEach(viewModel.assetList?.filter { $0.assetName?.hasSuffix(".usdz") ?? false } ?? []) { asset in
                        AssetRow(asset: asset, showDatasetDetailViewAction: {
                            self.showingSheet = true
                            self.selectedAsset = asset
                        })
                        .environmentObject(viewModel)
                    }
                }
                
                Section(header: Text("ML models")) {
                    ForEach(viewModel.assetList?.filter { $0.assetName?.hasSuffix(".mlmodel") ?? false } ?? []) { asset in
                        AssetRow(asset: asset, showDatasetDetailViewAction: {
                            self.showingSheet = true
                            self.selectedAsset = asset
                        })
                        .environmentObject(viewModel)
                    }
                }
                
                Section(header: Text("Guides")) {
                    ForEach(viewModel.guideList ?? []) { guide in
                        GuideRow(guide: guide, showGuideDetailViewAction: {
                            self.showingSheet = true
                            self.selectedGuide = guide
                        })
                        .environmentObject(viewModel)
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.removeModelsFromLocalStorage()
                    }) {
                        Text("REMOVE ALL ASSETS FROM DEVICE")
                            .foregroundColor(.red)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Dataset list")
            .sheet(isPresented: $showingSheet, onDismiss: {
                selectedAsset = nil
                selectedGuide = nil
            }) {
                DatasetDetailView(asset: $selectedAsset, guide: $selectedGuide)
            }
        }
    }
}

struct DatasetDetailView: View {
    @Binding var asset: Asset?
    @Binding var guide: Guide?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }
            
            Text((asset != nil) ? asset?.assetName ?? "" : (guide != nil) ? guide?.name ?? "" : "")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text((asset != nil) ? asset?.description ?? "" : (guide != nil) ? guide?._description ?? "" : "")
                .font(.callout)
                .padding(.bottom, 10)
            
            Spacer()
        }
        .padding()
    }
}

struct AssetRow: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    let asset: Asset
    let showDatasetDetailViewAction: () -> Void
    
    var body: some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Button(action: {
                            showDatasetDetailViewAction()
                        }) {
                            Text("\(asset.assetName ?? "")")
                                .font(.title3)
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Text("\(asset.description ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                if viewModel.downloadedAssets.contains(asset.assetName!) && !viewModel.selectedAssets.contains(asset.assetName!) {
                    Button(action: {
                        viewModel.selectMLModel(assetName: asset.assetName!)
                    }) {
                        Image(systemName: "circle")
                            .font(.system(size: 18))
                            .foregroundColor(.cyan)
                            .padding(.trailing)
                    }
                } else if viewModel.downloadedAssets.contains(asset.assetName!) && viewModel.selectedAssets.contains(asset.assetName!) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.cyan)
                        .padding(.trailing)
                }
                
                if viewModel.downloadedAssets.contains(asset.assetName!) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                } else {
                    Button(action: {
                        viewModel.getAssetByName(assetName: asset.assetName!)
                    }) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

struct GuideRow: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    let guide: Guide
    let showGuideDetailViewAction: () -> Void
    
    var body: some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Button(action: {
                            showGuideDetailViewAction()
                        }) {
                            Text("\(guide.name)")
                                .font(.title3)
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Text("\(guide._description ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                //                if viewModel.downloadedAssets.contains(asset.assetName!) {
                //                    Image(systemName: "checkmark.circle")
                //                        .font(.system(size: 24))
                //                        .foregroundColor(.green)
                //                } else {
                //                    Button(action: {
                //                        viewModel.getAssetByName(assetName: asset.assetName!)
                //                    }) {
                //                        Image(systemName: "arrow.down.to.line")
                //                            .font(.system(size: 24))
                //                            .foregroundColor(.green)
                //                    }
                //                }
            }
        }
    }
}

struct DatasetListView_Previews: PreviewProvider {
    static var previews: some View {
        DatasetListView().environmentObject(CollaborationViewModel())
    }
}
