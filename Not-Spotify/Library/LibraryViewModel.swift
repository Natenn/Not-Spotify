//
//  LibraryViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation
import SwiftNetwork

// MARK: - LibraryViewModel

final class LibraryViewModel: ObservableObject {
    @Published private(set) var playlists: [SimplifiedPlaylistObject] = []
    @Published private(set) var tracks: [SavedTrackObject] = []
    @Published private(set) var favouriteTracksCount: Int = 0

    @Published var isShowingSheet = false
    @Published var name: String = ""
    @Published var description: String = ""

    var isDisabled: Bool {
        name.isEmpty
    }

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

// MARK: - Crate Playlist

extension LibraryViewModel {
    func createPlaylist() {
        let request = Request(
            endpoint: Endpoint.createPlaylist(userId: AuthManager.shared.userId),
            method: .post,
            body: [
                APIKeys.name: name,
                APIKeys.description: description,
            ]
        )

        Task {
            try await Network.shared.execute(
                request,
                expecting: SimplifiedPlaylistObject.self,
                success: { _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.refreshPlaylists()
                        self?.isShowingSheet.toggle()
                        self?.name = ""
                        self?.description = ""
                    }
                }
            )
        }
    }
}
