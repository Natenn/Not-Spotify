//
//  PlaylistsResponseModel.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation

// MARK: - PlaylistsResponse

struct PlaylistsResponse: Decodable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [SimplifiedPlaylistObject]
}

// MARK: - SimplifiedPlaylistObject

struct SimplifiedPlaylistObject: Identifiable, Decodable {
    let collaborative: Bool
    let description: String
    let external_urls: ExternalUrls
    let href: String
    let id: String
    let images: [ImageObject]?
    let name: String
    let owner: Owner
    let `public`: Bool?
    let snapshot_id: String
    let tracks: Tracks
    let type: String
    let uri: String
}

// MARK: - Owner

struct Owner: Decodable {
    let id: String?
    let display_name: String?
}

// MARK: - PlaylistSnapshotId

struct PlaylistSnapshotId: Decodable {
    let snapshot_id: String
}

// MARK: - SimplifiedPlaylistObject + Extensions

extension SimplifiedPlaylistObject {
    var subtitle: LocalizedStringResource {
        let totalTracks = tracks.total ?? 0
        return "\(owner.display_name ?? "") · \(totalTracks) song"
    }

    var imageUrl: String? {
        images?.first?.url
    }

    var total: Int {
        tracks.total ?? 0
    }

    var ownerId: String {
        owner.id ?? ""
    }
}
