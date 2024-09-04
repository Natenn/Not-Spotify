//
//  PlaylistViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 26.08.24.
//

import Combine
import Foundation
import SwiftNetwork

final class PlaylistViewModel: ObservableObject {
    @Published var tracks: [Track] = []

    private var cancellables = Set<AnyCancellable>()

    var total: Int
    var endpoint: String
    var name: String

    private let offset = 20
    private(set) var currentOffset = 0

    init(name: String, total: Int, endpoint: String) {
        self.name = name
        self.total = total
        self.endpoint = endpoint
    }

    func fetchSongs(shouldOverwrite: Bool = false) {
        guard currentOffset < total else {
            return
        }

        let request = Request(
            endpoint: endpoint,
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        Network.shared.execute(request, expecting: TracksResponse.self)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                let tracks = response.items.map { $0.track }
                if shouldOverwrite {
                    self?.tracks = tracks
                } else {
                    self?.tracks.append(contentsOf: tracks)
                }
                self?.currentOffset += response.items.count
            }).store(in: &cancellables)
    }

    func refreshSongs() {
        currentOffset = 0
        fetchSongs(shouldOverwrite: true)
    }

    var shouldFetchMoreSongs: Bool {
        !tracks.isEmpty && currentOffset < total
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
