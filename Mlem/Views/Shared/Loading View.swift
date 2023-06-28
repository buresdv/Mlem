//
//  Loading View.swift
//  Mlem
//
//  Created by David Bureš on 01.04.2022.
//

import SwiftUI

struct LoadingView: View {
    enum PossibleThingsToLoad {
        case posts, image, comments, inbox, replies, mentions, messages
    }

    let whatIsLoading: PossibleThingsToLoad

    var body: some View {
        VStack {
            Spacer()

            ProgressView()
            switch whatIsLoading {
            case .posts:
                Text("Loading posts")
            case .image:
                Text("Loading image")
            case .comments:
                Text("Loading comments")
            case .inbox:
                Text("Loading inbox")
            case .replies:
                Text("Loading replies")
            case .mentions:
                Text("Loading mentions")
            case .messages:
                Text("Loading messages")
            }

            Spacer()
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity)
    }
}
