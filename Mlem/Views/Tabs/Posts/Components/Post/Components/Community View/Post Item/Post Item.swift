//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import CachedAsyncImage
import QuickLook
import SwiftUI

struct PostItem: View
{
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true

    @EnvironmentObject var appState: AppState

    @State var postTracker: PostTracker

    let post: Post

    @State var isExpanded: Bool

    @State var isInSpecificCommunity: Bool

    @State var account: SavedAccount

    @Binding var feedType: FeedType

    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false

    @State var isPostCollapsed: Bool = false
    
    @State var dragPosition: CGSize = .zero
    @State var ignoreDragPosition: Bool = false
    @State var dragBackground: Color = .systemBackground

    let iconToTextSpacing: CGFloat = 2
    
    let downvoteDragMin: CGFloat = 200;
    let upvoteDragMin: CGFloat = 50;
    let collapseDragMax: CGFloat = -50;
    
    func upvotePost() async -> Bool {
        do {
            switch post.myVote
            {
            case .upvoted:
                try await ratePost(post: post, operation: .resetVote, account: account, postTracker: postTracker, appState: appState)
            case .downvoted:
                try await ratePost(post: post, operation: .upvote, account: account, postTracker: postTracker, appState: appState)
            case .none:
                try await ratePost(post: post, operation: .upvote, account: account, postTracker: postTracker, appState: appState)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    func downvotePost() async -> Bool {
        do {
            switch post.myVote
            {
            case .upvoted:
                try await ratePost(post: post, operation: .downvote, account: account, postTracker: postTracker, appState: appState)
            case .downvoted:
                try await ratePost(post: post, operation: .resetVote, account: account, postTracker: postTracker, appState: appState)
            case .none:
                try await ratePost(post: post, operation: .downvote, account: account, postTracker: postTracker, appState: appState)
            }
        } catch {
            return false
        }
        
        return true
    }

    var body: some View
    {
        ZStack() {
            dragBackground
            VStack(alignment: .leading)
            {
                VStack(alignment: .leading, spacing: 15)
                {
                    HStack(alignment: .top)
                    {
                        if !isExpanded
                        { // Show this when the post is just in the list and not expanded
                            VStack(alignment: .leading, spacing: 8)
                            {
                                HStack
                                {
                                    if !isInSpecificCommunity
                                    {
                                        NavigationLink(destination: CommunityView(account: account, community: post.community, feedType: feedType))
                                        {
                                            HStack(alignment: .center, spacing: 10)
                                            {
                                                if shouldShowCommunityIcons
                                                {
                                                    if let communityAvatarLink = post.community.icon
                                                    {
                                                        AvatarView(avatarLink: communityAvatarLink, overridenSize: 30)
                                                    }
                                                }

                                                Text(post.community.name)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    }

                                    if post.stickied
                                    {
                                        Spacer()

                                        StickiedTag()
                                    }
                                }

                                Text(post.name)
                                    .font(.headline)
                            }
                        }
                        else
                        { // Show this when the post is expanded
                            VStack(alignment: .leading, spacing: 5)
                            {
                                if post.stickied
                                {
                                    StickiedTag()
                                }

                                Text(post.name)
                                    .font(.headline)
                            }
                            .onTapGesture
                            {
                                print("Tapped")
                                withAnimation(.easeIn(duration: 0.2))
                                {
                                    isPostCollapsed.toggle()
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading)
                    {
                        if let postURL = post.url
                        {
                            if postURL.pathExtension.contains(["jpg", "jpeg", "png"]) /// The post is an image, so show an image
                            {
                                if !isPostCollapsed
                                {
                                    CachedAsyncImage(url: postURL)
                                    { image in
                                        image
                                            .resizable()
                                            .frame(maxWidth: .infinity)
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                                    .stroke(Color(.secondarySystemBackground), lineWidth: 1.5)
                                            )
                                            .onTapGesture
                                            {
                                                isShowingEnlargedImage.toggle()
                                            }
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            else
                            {
                                if post.embedTitle != nil
                                {
                                    WebsiteIconComplex(post: post)
                                }
                                else
                                {
                                    WebsiteIconComplex(post: post)
                                }
                            }
                        }

                        if let postBody = post.body
                        {
                            if !postBody.isEmpty
                            {
                                if !isPostCollapsed
                                {
                                    MarkdownView(text: postBody)
                                        .onTapGesture
                                        {
                                            if (isExpanded) {
                                                withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                                                {
                                                    isPostCollapsed.toggle()
                                                }
                                            }
                                            print("Tapped")
                                        }
                                }
                            }
                        }
                    }
                }
                .padding()

                HStack
                {
                    // TODO: Refactor this into Post Interactions once I learn how to pass the vars further down
                    HStack(alignment: .center)
                    {
                        HStack(alignment: .center, spacing: 2)
                        {
                            Image(systemName: "arrow.up")

                            Text(String(post.score))
                        }
                        .if(post.myVote == .none || post.myVote == .downvoted)
                        { viewProxy in
                            viewProxy
                                .foregroundColor(.accentColor)
                        }
                        .if(post.myVote == .upvoted)
                        { viewProxy in
                            viewProxy
                                .foregroundColor(.green)
                        }
                        .onTapGesture
                        {
                            Task(priority: .userInitiated)
                            {
                                await upvotePost()
                            }
                        }

                        Image(systemName: "arrow.down")
                            .if(post.myVote == .downvoted)
                            { viewProxy in
                                viewProxy
                                    .foregroundColor(.red)
                            }
                            .if(post.myVote == .upvoted || post.myVote == .none)
                            { viewProxy in
                                viewProxy
                                    .foregroundColor(.accentColor)
                            }
                            .onTapGesture
                            {
                                Task(priority: .userInitiated)
                                {
                                    await downvotePost()
                                }
                            }

                        if let postURL = post.url
                        {
                            ShareButton(urlToShare: postURL, isShowingButtonText: false)
                        }
                    }

                    Spacer()

                    // TODO: Refactor this into Post Info once I learn how to pass the vars further down
                    HStack(spacing: 8)
                    {
                        HStack(spacing: iconToTextSpacing)
                        { // Number of comments
                            Image(systemName: "bubble.left")
                            Text(String(post.numberOfComments))
                        }

                        HStack(spacing: iconToTextSpacing)
                        { // Time since posted
                            Image(systemName: "clock")
                            Text(getTimeIntervalFromNow(date: post.published))
                        }

                        UserProfileLink(account: account, user: post.author)
                    }
                    .foregroundColor(.secondary)
                    .dynamicTypeSize(.small)
                }
                .padding(.horizontal)
                .if(!isExpanded, transform: { viewProxy in
                    viewProxy
                        .padding(.bottom)
                })

                if isExpanded
                {
                    Divider()
                }
            }
            .background(Color(uiColor: .systemBackground))
            .offset(x: ignoreDragPosition ? 0 : dragPosition.width)
            .gesture(
                DragGesture()
                    .onChanged {
                        ignoreDragPosition = false
                        let w = $0.translation.width
                        if w > downvoteDragMin {
                            dragBackground = .red
                        } else if w > upvoteDragMin {
                            dragBackground = .green
                        } else if $0.translation.width < collapseDragMax {
                            if let postBody = post.body
                            {
                                if !postBody.isEmpty {
                                    dragBackground = .blue
                                } else {
                                    dragBackground = .secondarySystemBackground
                                    ignoreDragPosition = true
                                }
                            } else {
                                dragBackground = .secondarySystemBackground
                                ignoreDragPosition = true
                            }
                        } else {
                            dragBackground = .secondarySystemBackground
                        }
                        dragPosition = $0.translation
                    }
                    .onEnded {
                        if $0.translation.width > downvoteDragMin {
                            Task(priority: .userInitiated) {
                                await downvotePost()
                            }
                        } else if $0.translation.width > upvoteDragMin {
                            Task(priority: .userInitiated) {
                                await upvotePost()
                            }
                        } else if $0.translation.width < collapseDragMax {
                            if let postBody = post.body
                            {
                                if !postBody.isEmpty {
                                    withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                                    {
                                        isPostCollapsed.toggle()
                                    }
                                }
                            }
                        }
                        dragPosition = .zero
                        dragBackground = .secondarySystemBackground
                    }
            )
        }
        
    }
}
