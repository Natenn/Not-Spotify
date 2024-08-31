//
//  PlaylistViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 26.08.24.
//

import Combine
import Foundation
import SwiftNetwork

class PlaylistViewModel: ObservableObject {
    private var playlist: SimplifiedPlaylistObject

    @Published var tracks: [Track] = []

    private var cancellables = Set<AnyCancellable>()

    init(playlist: SimplifiedPlaylistObject) {
        self.playlist = playlist
    }

    private let offset = 20
    private var currentOffset = 0

    func fetchSongs() {
        guard let totalTracks = playlist.tracks.total, currentOffset < totalTracks else {
            return
        }

        let request = Request(
            endpoint: Endpoint.playlistTracks(playlistId: playlist.id),
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        Network.shared.execute(request, expecting: TracksResponse.self)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.tracks.append(contentsOf: response.items.map { $0.track })
                self?.currentOffset += response.items.count
            }).store(in: &cancellables)
    }
    
    var shouldFetchMoreSongs: Bool {
        !tracks.isEmpty && currentOffset < playlist.tracks.total ?? 0
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
