//
//  ConfirmationView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI
import PhotosUI

struct ConfirmationView: View {
    @StateObject private var viewModel: ConfirmationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showFinalView: Bool = false
    private let progressHudBinding: ProgressHudBinding
    
    init(viewModel: ConfirmationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            rating
            divider
            comment
            divider
            uploadPhoto
            Spacer()
            buttonsStack
        }
        .ignoresSafeArea(.keyboard)
        .padding()
        .navigationTitle(L.Confirmation.title)
        .navigationBarTitleDisplayMode(.large)
        .background(
            Color("backgroundColor")
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture {
                    hideKeyboard()
                }
        )
        .navigationDestination(isPresented: $showFinalView) {
            FinalView()
        }
    }
}

private extension ConfirmationView {
    var rating: some View {
        VStack(alignment: .leading) {
            Text(L.Confirmation.rating)
                .font(.system(size: 15))
                .foregroundColor(Color("disabledColor"))
                .padding(.bottom, 8)
            
            HStack {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < viewModel.selectedRating ? "star.fill" : "star")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                        .onTapGesture { viewModel.selectedRating = index + 1 }
                }
                Spacer()
            }
        }
    }
    var divider: some View {
        Divider()
            .background(Color("dividerColor"))
            .padding(.vertical, 24)
    }
    var comment: some View {
        VStack(alignment: .leading) {
            Text(L.Confirmation.comment)
                .font(.system(size: 15))
                .foregroundColor(Color("disabledColor"))
                .padding(.bottom, 8)
            TextField(
                L.Confirmation.commentPlaceholder,
                text: $viewModel.comment,
                axis: .vertical
            )
            .lineLimit(3...)
            .foregroundColor(.white)
            .padding(10)
            .background(Color("dividerColor"))
            .cornerRadius(8)
            .foregroundColor(Color("disabledColor"))
        }
    }
    var uploadPhoto: some View {
        VStack(alignment: .leading) {
            Text(L.Confirmation.image)
                .font(.system(size: 15))
                .foregroundColor(Color("disabledColor"))
                .padding(.bottom, 8)
            
            HStack(alignment: .top, spacing: 20) {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color("dividerColor"))
                                    .frame(width: 85, height: 85)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(Color("disabledColor"))
                            }
                            
                            Text(L.Confirmation.uploadImage)
                                .font(.system(size: 10))
                                .foregroundColor(Color.white)
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 85)
                        .cornerRadius(8)
                }
            }
        }
    }
    var buttonsStack: some View {
        HStack {
            Button(L.Confirmation.cancel){
                dismiss()
            }
            .buttonStyle(ButtonStyledOutline())
            Button(L.Confirmation.confirm){
                if viewModel.isLastStep {
                    Task {
                        await viewModel.onConfirmationAction()
                    }
                    showFinalView.toggle()
                } else {
                    Task {
                        await viewModel.onConfirmationAction()
                    }
                }
            }
            .buttonStyle(ButtonStyledFill())
        }
    }
}

#Preview {
    ConfirmationView(
        viewModel: ConfirmationViewModel(
            guideId: "",
            stepId: "",
            onStepConfirmation: {}
        )
    )
}
