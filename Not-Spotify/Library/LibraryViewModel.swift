//
//  LibraryViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation
import SwiftNetwork

final class LibraryViewModel: ObservableObject {
    @Published var playlists: [SimplifiedPlaylistObject] = []
    @Published var tracks: [SavedTrackObject] = []
    @Published var favouriteTracksCount: Int = 0

    private var total = 0
    private let offset = 20
    private var currentOffset = 0

    func fetchPlaylists(shouldOverwrite: Bool = false) {
        let request = Request(
            endpoint: Endpoint.savedPlaylists,
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: PlaylistsResponse.self, success: { response in
                DispatchQueue.main.async { [weak self] in
                    if shouldOverwrite {
                        self?.playlists = []
                    }
                    self?.playlists.append(contentsOf: response.items)
                    self?.currentOffset += response.items.count
                    self?.total = response.total
                }
            })
        }
    }

    func fetchFavourites() {
        let request = Request(
            endpoint: Endpoint.savedTracks,
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: TracksResponse.self, success: { response in
                DispatchQueue.main.async { [weak self] in
                    self?.tracks = response.items
                    self?.favouriteTracksCount = response.total
                }
            })
        }
    }

    func unfollowPlaylist(playlistId: String) {
        let request = Request(
            endpoint: Endpoint.playlistFollowers(playlistId: playlistId),
            method: .delete
        )

        Task {
            try await Network.shared.execute(request, expecting: EmptyResponse.self, success: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.playlists.removeAll(where: {
                        $0.id == playlistId
                    })
                }
            })
        }
    }

    func refreshPlaylists() {
        currentOffset = 0
        fetchFavourites()
        fetchPlaylists(shouldOverwrite: true)
    }

    var shouldFetchMorePlaylists: Bool {
        !playlists.isEmpty && currentOffset < total
    }
}
