//
//  ConfirmationView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 19.07.2023.
//

import SwiftUI
import PhotosUI

struct ConfirmationView: View {
    private enum Field: Int, CaseIterable {
        case notes
    }
    
    let guide: ExtendedGuideResponse?
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedRating: Int = 0
    @State private var notes: String = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Rating")
                .font(.system(size: 15))
                .foregroundColor(Color("disabledColor"))
                .padding(.bottom, 8)
            
            HStack {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < selectedRating ? "star.fill" : "star")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                        .onTapGesture {
                            // Update the selectedRating when a star is tapped
                            selectedRating = index + 1
                        }
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color("dividerColor"))
                .padding(.top, 16)
                .padding(.bottom, 32)
            
            Text("Notes")
                .font(.system(size: 15))
                .foregroundColor(Color("disabledColor"))
                .padding(.bottom, 8)
            
            TextField("Text", text: $notes, axis: .vertical)
                .focused($focusedField, equals: .notes)
                .frame(width: .infinity, height: 100, alignment: .top)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color("dividerColor"))
                .cornerRadius(8)
            
            Divider()
                .background(Color("dividerColor"))
                .padding(.top, 16)
                .padding(.bottom, 32)
            
            Text("Photo")
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
                            
                            Text("Upload photo")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white)
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            // Retrieve selected asset in the form of Data
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
            
            Spacer()
            
            HStack {
                Button("Cancel"){
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(ButtonStyledOutline())
                
                Button("Confirm"){
                    // TODO: - send confirmation request
                    self.presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(ButtonStyledFill())
            }
        }
        .padding()
        .navigationTitle("Step 1 confirmation")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("backgroundColor")
            .ignoresSafeArea(.all, edges: .all))
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color("backgroundColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(guide: ExtendedGuideResponse(name: "", guideType: .tutorial))
    }
}
