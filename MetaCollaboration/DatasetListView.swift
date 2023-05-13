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
                Section(header: Text("Guides")) {
                    ForEach(viewModel.guideList ?? []) { guide in
                        GuideRow(guide: guide, isLoading: $viewModel.assetsDownloadingCount, showGuideDetailViewAction: {
                            self.showingSheet = true
                            self.selectedGuide = guide
                        })
                        .environmentObject(viewModel)
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.removeDatasetFromLocalStorage()
                    }) {
                        Text("REMOVE ALL DATASETS FROM DEVICE")
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
                DatasetDetailView(guide: $selectedGuide, currentGuide: $viewModel.currentGuide, downloadedAssets: $viewModel.downloadedAssets, selectedAssets: $viewModel.selectedAssets, isLoading: $viewModel.assetsDownloadingCount)
            }
        }
    }
}

struct DatasetDetailView: View {
    @Binding var guide: Guide?
    @Binding var currentGuide: ExtendedGuide?
    @Binding var downloadedAssets: [String]
    @Binding var selectedAssets: [String]
    @Binding var isLoading: Int
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
            
            Text(guide?.name ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text(guide?._description ?? "")
                .font(.callout)
                .padding(.bottom, 10)
            
            HStack {
                Text(guide?.guideType.rawValue ?? "")
                    .font(.caption)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.green, lineWidth: 1)
                    )
                    .padding(.trailing, 8)
                
                if currentGuide?.objectSteps != nil {
                    Text("Steps: \(currentGuide?.objectSteps?.count ?? 0)")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.green, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            
            Divider()
            
            VStack {
                if downloadedAssets != [] {
                    Text("DOWNLOADED ASSETS")
                        .font(.callout.bold())
                        .padding(.bottom, 6)
                    
                    ForEach(downloadedAssets, id: \.self) { asset in
                        HStack {
                            Text(asset)
                                .font(.callout)
                                .padding(.bottom, 10)
                            Spacer()
                            
                            if selectedAssets.contains(asset) {
                                Text("SELECTED")
                                    .font(.system(.caption2).weight(.bold))
                                    .foregroundColor(.green)
                                    .padding(.trailing, 2)
                                
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                
                if isLoading > 0 {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.green))
                            .zIndex(2)
                        
                        Text("Loading models...")
                            .font(.system(.caption).weight(.bold))
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding()
    }
}

struct GuideRow: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    let guide: Guide
    @Binding var isLoading: Int
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
                
                if isLoading > 0 {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.green))
                        .zIndex(2)
                        .padding(.trailing, 2)
                }
                
                if viewModel.currentGuide?.name == guide.name {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                } else {
                    Button(action: {
                        viewModel.getGuideById(id: guide.id!)
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

struct DatasetListView_Previews: PreviewProvider {
    static var previews: some View {
        DatasetListView().environmentObject(CollaborationViewModel())
    }
}
