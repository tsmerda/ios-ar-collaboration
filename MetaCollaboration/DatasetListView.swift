//
//  DatasetListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct DatasetListView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    @State private var showingSheet = false
    @State private var selectedDataset: Dataset?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Datasets")) {
                    ForEach(viewModel.datasetList) { dataset in
                        Button(action: {}) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text("\(dataset.title)")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .fontWeight(.semibold)
                                        Button(action: {
                                            self.selectedDataset = dataset
                                            self.showingSheet = true
                                        }) {
                                            Image(systemName: "questionmark.circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color.gray)
                                        }
                                    }
                                    
                                    Text("\(dataset.desc)")
                                        .font(.subheadline)
                                        .foregroundColor(Color.gray)
                                }
                                
                                Spacer()
                                
                                if viewModel.selectedDataset == URL(string: dataset.url)!.lastPathComponent {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                } else {
                                    Button(action: {
                                        viewModel.download(dataset.url)
                                    }) {
                                        Image(systemName: "arrow.down.to.line")
                                            .font(.system(size: 24))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dataset list")
            .sheet(isPresented: $showingSheet) {
                DatasetDetailView(dataset: $selectedDataset)
            }
        }
    }
}

struct DatasetDetailView: View {
    @Binding var dataset: Dataset?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
            
            Text(dataset?.title ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text(dataset?.desc ?? "")
                .font(.callout)
                .padding(.bottom, 10)
            
            Image(dataset?.image ?? "")
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
                .padding(.bottom, 10)
            
            Text(dataset?.info ?? "")
                .font(.callout)
            
            Spacer()
        }
        .padding()
    }
}

struct DatasetListView_Previews: PreviewProvider {
    static var previews: some View {
        DatasetListView()
    }
}
