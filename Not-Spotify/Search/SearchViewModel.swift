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
    
    private var network: Networkable

    @Published var areSaved = [String: Bool]()
    @Published var areCollected = [String: Bool]()
    
    @Published var isShowingSheet = false
    @Published var query: String = ""

    private let offset = 10
    private var currentOffset = 0
    
    init(network: Networkable = Network.shared) {
        self.network = network
    }

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
            try await network.execute(request, expecting: SearchResponseModel.self, success: { response in
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
            }, failure: { _ in })
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

// MARK: - SearchViewModel + ContextMenuableTrack

extension SearchViewModel: ContextMenuableTrack {
    var ownerId: String {
        ""
    }
    
    var id: String {
        ""
    }
    
    var snapshotId: String {
        ""
    }
    
    func addItemToPlaylist() {
        isShowingSheet.toggle()
    }
    
    var endpoint: String { "" }

    func removeTrack(by _: String) {}

    func updateTrackStatus(for trackId: String, isSaved: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.areSaved[trackId] = isSaved
        }
    }
}

// MARK: - SearchViewModel + ContextMenuablePlaylist

extension SearchViewModel: ContextMenuablePlaylist {
    func updatePlaylistStatus(for playlistId: String, isCollected: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.areCollected[playlistId] = isCollected
        }
    }
}
