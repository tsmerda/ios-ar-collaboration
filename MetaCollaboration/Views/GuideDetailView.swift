//
//  GuideDetailView.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.07.2023.
//

import SwiftUI

struct GuideDetailView: View {
    @StateObject private var viewModel: GuideDetailViewModel
    @EnvironmentObject var nav: NavigationStateManager
    private let progressHudBinding: ProgressHudBinding
    
    init(viewModel: GuideDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.progressHudBinding = ProgressHudBinding(state: viewModel.$progressHudState)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    guideTitle
                    guideDescription
                    guideImage
                    // guideDetail
                }
            }
            Spacer()
            // TODO: -- add LOADING PROGRESS
            buttonsLabel
            buttonsStack
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color("backgroundColor"))
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isGuideCompleted {
                    Text("Completed")
                        .font(.system(size: 10).weight(.bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 3)
                        .background(Color.accentColor)
                        .cornerRadius(6)
                }
            }
        }
        .navigationDestination(for: ExtendedGuideResponse.self) { guide in
            CollaborationView(
                viewModel: CollaborationViewModel(
                    currentGuide: guide,
                    referenceObjects: viewModel.referenceObjects
                )
            )
        }
        .onAppear {
            viewModel.downloadedGuides = PersistenceManager.shared.loadGuidesFromJSON()
        }
    }
}

private extension GuideDetailView {
    var guideTitle: some View {
        HStack(alignment: .top) {
            Text(viewModel.guide.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            Text(viewModel.guide.guideType.rawValue.capitalized)
                .font(.system(size: 17))
                .foregroundColor(.accentColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(16)
        }
    }
    var guideDescription: some View {
        Text(viewModel.guide.description ?? "Guide description")
            .font(.subheadline)
            .foregroundColor(Color("disabledColor"))
            .multilineTextAlignment(.leading)
            .padding(.bottom, 8)
    }
    // TODO: -- add loader while loading
    @ViewBuilder
    var guideImage: some View {
        if let imageUrl = viewModel.guide.imageUrl {
            AsyncImage(url: URL(string: imageUrl)){ image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
            } placeholder: { Color("secondaryColor") }
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    //    var guideDetail: some View {
    //        if viewModel.downloadedGuide {
    //            GuideDetailInfoView(objectSteps: viewModel.downloadedGuide?.objectSteps)
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
            
            // TODO: -- Add loading until all of referenceObjects are downloaded
            Button("Begin guide") {
                if let guideId = viewModel.guide.id {
                    viewModel.onSetCurrentGuideAction(guideId)
                    if let currentGuide = viewModel.currentGuide,
                       !viewModel.referenceObjects.isEmpty {
                        nav.goToCollaborationView(currentGuide)
                    } else {
                        nav.errorGoToView("Collaboration view")
                    }
                }
            }
            .buttonStyle(ButtonStyledFill())
            .disabled(!viewModel.downloadedGuide || viewModel.referenceObjects.isEmpty)
        }
    }
}

#Preview {
    GuideDetailView(
        viewModel: GuideDetailViewModel(
            guide: Guide.example
        )
    )
}
