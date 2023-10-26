//
//  GuideDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct GuideDetailView: View {
    @StateObject private var viewModel: GuideDetailViewModel
    @Environment(\.dismiss) private var dismiss
    //    @Binding var path: NavigationPath
    private let progressHudBinding: ProgressHudBinding
    
    init(viewModel: GuideDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    guideTitle
                    guideDescription
                    guideImage
                    // guideDetail
                }
            }
            Spacer()
            buttonsLabel
            buttonsStack
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color("backgroundColor"))
        //        .navigationDestination(isPresented: $showCollaborationView) {
        //            if let currentGuide = viewModel.currentGuide {
        //                CollaborationView(
        //                    viewModel: CollaborationViewModel(
        //                        currentGuide: currentGuide,
        //                        referenceObjects: viewModel.referenceObjects
        //                    )
        //                )
        //                .onDisappear {
        //                    // Deinitialize CollaborationViewModel
        //                    debugPrint("CollaborationView disappear")
        //                    viewModel.currentGuide = nil
        //                }
        //            }
        //        }
    }
}

private extension GuideDetailView {
    var guideTitle: some View {
        HStack(alignment: .center) {
            Text(viewModel.guide.name)
                .font(.system(size: 24).bold())
                .foregroundColor(.white)
            Spacer()
            Text(viewModel.guide.guideType.rawValue.capitalized)
                .font(.system(size: 17))
                .foregroundColor(.accentColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(16)
        }
        .padding(.bottom)
    }
    var guideDescription: some View {
        Text(viewModel.guide.description ?? "Guide description")
            .font(.subheadline)
            .foregroundColor(Color("disabledColor"))
            .multilineTextAlignment(.leading)
            .padding(.bottom, 24)
    }
    @ViewBuilder
    var guideImage: some View {
        if let imageUrl = viewModel.guide.imageUrl {
            AsyncImage(url: URL(string: imageUrl)){ image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(8)
            } placeholder: { Color("secondaryColor") }
                .frame(width: .infinity, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 16)
        }
    }
    //    var guideDetail: some View {
    //        if downloadedGuide != nil {
    //            GuideDetailInfoView(objectSteps: downloadedGuide?.objectSteps)
    //        } else {
    //            Text("To show the detailed steps, you need to download this guide.")
    //                .font(.system(size: 13).bold())
    //                .foregroundColor(.accentColor)
    //        }
    //    }
    var buttonsLabel: some View {
        HStack {
            Spacer()
            if viewModel.downloadedGuide {
                Text("This guide is already downloaded")
                    .font(.system(size: 13).bold())
                    .foregroundColor(.accentColor)
            } else {
                Text("This guide is not downloaded yet")
                    .font(.system(size: 13).bold())
                    .foregroundColor(.accentColor)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    var buttonsStack: some View {
        HStack {
            Button("Download guide") {
                if let guideId = viewModel.guide.id {
                    viewModel.getGuideById(guideId)
                }
            }
            .buttonStyle(ButtonStyledOutline())
            .disabled(viewModel.downloadedGuide)
            
            Button("Begin guide") {
                if let guideId = viewModel.guide.id {
                    viewModel.onSetCurrentGuideAction(guideId)
                }
            }
            .buttonStyle(ButtonStyledFill())
            .disabled(!viewModel.downloadedGuide)
        }
    }
}

#Preview {
    GuideDetailView(
        viewModel: GuideDetailViewModel(
            guide: Guide.example,
            downloadedGuides: [ExtendedGuideResponse.example],
            onDownloadGuide: { _ in }
            //            onGetGuide: {}
            //            onSetCurrentGuide: {}
        )
    )
}
