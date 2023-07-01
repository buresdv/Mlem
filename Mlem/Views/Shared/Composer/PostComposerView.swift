//
//  PostComposerView.swift
//  Mlem
//
//  Created by Weston Hanners on 6/29/23.
//

import SwiftUI

struct PostComposerView: View {
    
    init(community: APICommunity) {
        self.community = community
    }
    
    var community: APICommunity
    
    let iconWidth: CGFloat = 24
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState

    @State var postTitle: String = ""
    @State var postURL: String = ""
    @State var postBody: String = ""
    @State var isNSFW: Bool = false
    
    @State var isSubmitting: Bool = false
    
    func submitPost() async {
        do {
            guard let account = appState.currentActiveAccount else {
                print("Cannot Submit, No Active Account")
                return
            }
            
            isSubmitting = true
            
            try await postPost(to: community,
                               postTitle: postTitle,
                               postBody: postBody,
                               postURL: postURL,
                               postIsNSFW: isNSFW,
                               postTracker: postTracker,
                               account: account)
            
            print("Post Successful")
            
            dismiss()
            
        } catch {
            print("Something went wrong)")
        }
        print("Submitting")
    }
    
    func uploadImage() {
        print("Uploading")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 15) {
                    
                    // Community Row
                    HStack {
                        CommunityLinkView(shouldShowCommunityIcons: true,
                                          community: community)
                        .disabled(true)
                        Spacer()
                        // NSFW Toggle
                        NSFWToggle(compact: false, isEnabled: isNSFW)
                    }
                    
                    // Title Row
                    HStack {
                        Text("Title")
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                        TextField("", text: $postTitle)
                        .accessibilityLabel("Title")
                    }
                    
                    // URL Row
                    HStack {
                        Text("URL")
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                        TextField("", text: $postURL)
                        .autocorrectionDisabled()
                        .accessibilityLabel("URL")

                        
                        // Upload button, temporarily hidden
//                        Button(action: uploadImage) {
//                            Image(systemName: "paperclip")
//                                .font(.title3)
//                                .dynamicTypeSize(.medium)
//                        }
//                        .accessibilityLabel("Upload Image")
                    }
                    
                    // Post Text
                    TextField("What do you want to say?",
                              text: $postBody,
                              axis: .vertical)
                    .accessibilityLabel("Post Body")
                    Spacer()
                }
                .padding()
                
                // Loading Indicator
                if isSubmitting {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Submitting Post")
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
                }
            }

            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Submit Button
                    Button {
                        Task(priority: .userInitiated) {
                            await submitPost()
                        }
                    } label: {
                        Image(systemName: "paperplane")
                    }.disabled(isSubmitting)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PostComposerView_Previews: PreviewProvider {
    static let community = generateFakeCommunity(id: 1,
                                                 namePrefix: "mlem")
        
    static var previews: some View {
        NavigationStack {
            PostComposerView(community: community)
        }
    }
}
