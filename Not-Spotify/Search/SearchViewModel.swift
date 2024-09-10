//
//  SearchViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 05.09.24.
//

import Foundation
import SwiftNetwork

// MARK: - SearchViewModel

final class SearchViewModel: ObservableObject {
    @Published var searchResults = [SearchResult]()

    @Published var areSaved = [String: Bool]()
    @Published var areCollected = [String: Bool]()

    @Published var query: String = ""

    private let offset = 10
    private var currentOffset = 0

    func fetchItems(shouldOverwrite: Bool = true) {
        guard !query.isEmpty else {
            return
        }

        let request = Request(
            endpoint: Endpoint.search,
            query: [
                APIKeys.query: query.queryString,
                APIKeys.type: APIConstants.searchedTypes,
                APIKeys.limit: offset,
                APIKeys.offset: shouldOverwrite ? 0 : currentOffset,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: SearchResponseModel.self, success: { response in
                DispatchQueue.main.async { [weak self] in
                    if shouldOverwrite {
                        self?.searchResults = []
                        self?.areSaved = [:]
                        self?.areCollected = [:]
                    }

                    self?.searchResults.append(contentsOf: response.tracks.items.compactMap {
                        .track(track: $0)
                    })
                    self?.searchResults.append(contentsOf: response.playlists.items.compactMap {
                        .playlist(playlist: $0)
                    })

                    for track in response.tracks.items {
                        self?.checkSavedTracks(by: track.id)
                    }
                    for playlist in response.playlists.items {
                        self?.checkFollowedPlaylists(by: playlist.id)
                    }

                    self?.currentOffset += response.playlists.items.count + response.tracks.items.count
                }
            })
        }
    }

    func fetchMoreItems() {
        fetchItems(shouldOverwrite: false)
    }

    var shouldFetchMoreItems: Bool {
        !searchResults.isEmpty && !query.isEmpty
    }
}

// MARK: - Extension

extension String {
    var queryString: String {
        replacingOccurrences(of: " ", with: "%20")
    }
}

// MARK: - Context Menu for tracks

extension SearchViewModel {
    func contextMenuItems(trackId: String) -> [ContextMenuItem] {
        var items = [ContextMenuItem]()

        if areSaved[trackId] == true {
            items.append(ContextMenuItem(
                id: 0,
                label: "Remove from Favourites",
                systemName: "minus.circle",
                action: { [weak self] in
                    self?.toggleSavedTrack(by: trackId)
                }
            ))
        } else {
            items.append(ContextMenuItem(
                id: 0,
                label: "Add to Favourites",
                systemName: "heart",
                action: { [weak self] in
                    self?.toggleSavedTrack(by: trackId)
                }
            ))
        }

        items.append(ContextMenuItem(
            id: 1,
            label: "Add to Playlist",
            systemName: "bookmark",
            action: { /* TODO: Implement */ }
        ))

        return items
    }

    private func toggleSavedTrack(by trackId: String) {
        let request = Request(
            endpoint: Endpoint.savedTracks,
            method: savedTracksMethod(for: trackId),
            body: [
                APIKeys.ids: [trackId],
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: EmptyResponse.self, success: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.areSaved[trackId]?.toggle()
                }
            })
        }
    }

    private func checkSavedTracks(by id: String) {
        let request = Request(
            endpoint: Endpoint.checkSavedTracks,
            query: [
                APIKeys.ids: id,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: [Bool].self, success: { response in
                DispatchQueue.main.sync { [weak self] in
                    self?.areSaved[id] = response.first
                }
            })
        }
    }

    private func savedTracksMethod(for trackId: String) -> HTTPMethod {
        guard let isSaved = areSaved[trackId] else {
            return .put
        }

        if isSaved {
            return .delete
        }

        return .put
    }
}

// MARK: - Context Menu for playlists

extension SearchViewModel {
    func contextMenuItems(playlistId: String) -> [ContextMenuItem] {
        var items = [ContextMenuItem]()

        if areCollected[playlistId] == true {
            items.append(ContextMenuItem(
                id: 0,
                label: "Remove from Library",
                systemName: "bookmark.slash",
                action: { [weak self] in
                    self?.toggleSavedPlaylist(by: playlistId)
                }
            ))
        } else {
            items.append(ContextMenuItem(
                id: 0,
                label: "Add to Library",
                systemName: "bookmark",
                action: { [weak self] in
                    self?.toggleSavedPlaylist(by: playlistId)
                }
            ))
        }

        return items
    }

    private func toggleSavedPlaylist(by playlistId: String) {
        let request = Request(
            endpoint: Endpoint.playlistFollowers(playlistId: playlistId),
            method: savedPlaylistsMethod(for: playlistId)
        )

        Task {
            try await Network.shared.execute(request, expecting: EmptyResponse.self, success: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.areCollected[playlistId]?.toggle()
                }
            })
        }
    }

    private func checkFollowedPlaylists(by id: String) {
        let request = Request(
            endpoint: Endpoint.playlistFollowersContains(playlistId: id),
            query: [
                APIKeys.playlistId: id,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: [Bool].self, success: { response in
                DispatchQueue.main.sync { [weak self] in
                    self?.areCollected[id] = response.first
                }
            })
        }
    }

    private func savedPlaylistsMethod(for playlistId: String) -> HTTPMethod {
        guard let isSaved = areCollected[playlistId] else {
            return .put
        }

        if isSaved {
            return .delete
        }

        return .put
    }
}
