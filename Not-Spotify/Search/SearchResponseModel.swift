//
//  SearchResponseModel.swift
//  Not-Spotify
//
//  Created by Naten on 05.09.24.
//

import Foundation

// MARK: - SearchResponseModel

struct SearchResponseModel: Decodable {
    let tracks: TracksSearchResponse
    let playlists: PlaylistsResponse
}

// MARK: - SearchResult

enum SearchResult: Identifiable {
    case track(track: Track)
    case playlist(playlist: SimplifiedPlaylistObject)

    var id: String {
        switch self {
        case let .track(track: track):
            track.id
        case let .playlist(playlist: playlist):
            playlist.id
        }
    }
}
