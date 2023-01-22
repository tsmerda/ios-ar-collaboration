//
//  DatasetListView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 22.01.2023.
//

import SwiftUI

struct DatasetListView: View {
    @EnvironmentObject var viewModel: CollaborationViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Datasets")) {
                    ForEach(viewModel.datasetList) { dataset in
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(dataset.title)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
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
                                    viewModel.textData = "Jdwadwadwa"
                                    viewModel.isLoading = true
                                    viewModel.download(dataset.url)
                                }) {
                                    Image(systemName: "arrow.down.to.line")
                                        .font(.system(size: 24))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dataset list")
        }
    }
}

struct DatasetListView_Previews: PreviewProvider {
    static var previews: some View {
        DatasetListView()
    }
}
