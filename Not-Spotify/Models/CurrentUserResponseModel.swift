//
//  CurrentUserResponseModel.swift
//  Not-Spotify
//
//  Created by Naten on 11.09.24.
//

import Foundation

struct CurrentUserResponseModel: Decodable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: ExplicitContent
    let external_urls: ExternalUrls
    let followers: Followers
    let href: String
    let id: String
    let images: [ImageObject]
    let product: String
    let type: String
    let uri: String
}

struct ExplicitContent: Decodable {
    let filter_enabled: Bool
    let filter_locked: Bool
}

struct Followers: Decodable {
    let href: String?
    let total: Int
}
