//
//  PlaylistsResponseModel.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation

struct PlaylistsResponse: Decodable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [SimplifiedPlaylistObject]
}

struct SimplifiedPlaylistObject: Identifiable, Decodable {
    let collaborative: Bool
    let description: String
    let external_urls: ExternalUrls
    let href: String
    let id: String
    let images: [ImageObject]
    let name: String
    let owner: Owner
    let `public`: Bool?
    let snapshot_id: String
    let tracks: Tracks
    let type: ItemType
    let uri: String
}

struct Owner: Decodable {
    let id: String
    let display_name: String?
}
