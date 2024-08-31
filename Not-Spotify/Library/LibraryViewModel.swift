//
//  LibraryViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Combine
import Foundation
import SwiftNetwork

// MARK: - LibraryViewModel

final class LibraryViewModel: ObservableObject {
    @Published var playlists: [SimplifiedPlaylistObject] = []
    @Published var tracks: [SavedTrackObject] = []
    @Published var favouriteTracksCount: Int?

    private var total = 0
    private let offset = 20
    private var currentOffset = 0

    private var cancellables = Set<AnyCancellable>()
    
    func fetchPlaylists() {
        let request = Request(
            endpoint: Endpoint.savedPlaylists,
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        Network.shared.execute(request, expecting: PlaylistsResponse.self)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.playlists.append(contentsOf: response.items)
                self?.currentOffset += response.items.count
                self?.total = response.total
            }).store(in: &cancellables)
    }

    func fetchFavourites() {
        let request = Request(
            endpoint: Endpoint.savedTracks,
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        Network.shared.execute(request, expecting: TracksResponse.self)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.tracks = response.items
                self?.favouriteTracksCount = response.total
            }).store(in: &cancellables)
    }
    
    var shouldFetchMorePlaylists: Bool {
        !playlists.isEmpty && currentOffset < total
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
