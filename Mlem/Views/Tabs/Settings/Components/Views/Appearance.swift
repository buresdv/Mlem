//
//  Appearance.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct AppearanceSettingsView: View {
    
    @Preference(\.shouldShowWebsitePreviews) var shouldShowWebsitePreviews
    @Preference(\.shouldShowWebsiteFaviconAtAll) var shouldShowWebsiteFaviconAtAll
    @Preference(\.shouldShowWebsiteHost) var shouldShowWebsiteHost
    
    @Preference(\.shouldShowCompactPosts) var shouldShowCompactPosts
    @Preference(\.shouldShowWebsiteFavicons) var shouldShowWebsiteFavicons
    @Preference(\.shouldShowUserAvatars) var shouldShowUserAvatars
    @Preference(\.shouldShowCommunityIcons) var shouldShowCommunityIcons
    
    @Preference(\.shouldShowCommunityHeaders) var shouldShowCommunityHeaders
    
    @Preference(\.voteComplexStyle) var voteComplexStyle
    
    var body: some View {
        List
        {
            Section("Website Previews")
            {
                WebsiteIconComplex(post:
                                    APIPost(
                                        id: 0,
                                        name: "",
                                        url: URL(string: "https://lemmy.ml/post/1011734")!,
                                        body: "",
                                        creatorId: 0,
                                        communityId: 0,
                                        deleted: false,
                                        embedDescription: nil,
                                        embedTitle: "I am an example of a website preview.\nCustomize me!",
                                        embedVideoUrl: nil,
                                        featuredCommunity: false,
                                        featuredLocal: false,
                                        languageId: 0,
                                        apId: "https://lemmy.ml/post/1011068",
                                        local: true,
                                        locked: false,
                                        nsfw: false,
                                        published: .now,
                                        removed: false,
                                        thumbnailUrl: URL(string: "https://lemmy.ml/pictrs/image/1b759945-6651-497c-bee0-9bdb68f4a829.png"),
                                        updated: nil
                                    )
                                   )
                
                .padding(.horizontal)
                
                SettingsItem(
                    settingPictureSystemName: "photo.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show website image",
                    isTicked: $shouldShowWebsitePreviews
                )
                SettingsItem(
                    settingPictureSystemName: "globe",
                    settingPictureColor: .pink,
                    settingName: "Show website icons",
                    isTicked: $shouldShowWebsiteFaviconAtAll
                )
                .onChange(of: shouldShowWebsiteFaviconAtAll) { newValue in
                    if shouldShowWebsiteFaviconAtAll == false
                    {
                        shouldShowWebsiteFavicons = false
                    }
                    else
                    {
                        shouldShowWebsiteFavicons = true
                    }
                }
                SettingsItem(
                    settingPictureSystemName: "network",
                    settingPictureColor: .pink,
                    settingName: "Show website address",
                    isTicked: $shouldShowWebsiteHost
                )
            }
            Section("Posts")
            {
                SettingsItem(
                    settingPictureSystemName: "wifi.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show dynamic website icons",
                    isTicked: $shouldShowWebsiteFavicons
                )
                .disabled(!shouldShowWebsiteFaviconAtAll)
                
                SettingsItem(settingPictureSystemName: "rectangle.compress.vertical",
                             settingPictureColor: .pink,
                             settingName: "Compact post view",
                             isTicked: $shouldShowCompactPosts)
            }
            
            Section("Communities")
            {
                SettingsItem(
                    settingPictureSystemName: "rectangle.grid.1x2",
                    settingPictureColor: .pink,
                    settingName: "Show community headers",
                    isTicked: $shouldShowCommunityHeaders
                )
            }
            
            Section("Icons")
            {
                SettingsItem(
                    settingPictureSystemName: "person.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show user avatars",
                    isTicked: $shouldShowUserAvatars
                )
                
                SettingsItem(
                    settingPictureSystemName: "person.2.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show community icons",
                    isTicked: $shouldShowCommunityIcons
                )
            }
            
            Section("Customization") {
                Picker("Vote complex style", selection: $voteComplexStyle) {
                    ForEach(VoteComplexStyle.allCases) { style in
                        Text(style.rawValue.capitalized)
                    }
                }

            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
