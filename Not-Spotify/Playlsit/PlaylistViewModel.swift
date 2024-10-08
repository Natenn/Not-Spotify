//
//  PlaylistViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 26.08.24.
//

import Foundation
import SwiftNetwork

// MARK: - PlaylistViewModel

final class PlaylistViewModel: ObservableObject {
    @Published private(set) var tracks = [Track]()

    @Published var areSaved = [String: Bool]()

    @Published var isShowingSheet = false
    
    private var network: Networkable

    var id: String
    var snapshotId: String
    var ownerId: String
    var total: Int
    var endpoint: String
    var name: LocalizedStringResource

    private let offset = 20
    private(set) var currentOffset = 0

    init(network: Networkable = Network.shared, id: String, snapshotId: String, ownerId: String, name: LocalizedStringResource, total: Int, endpoint: String) {
        self.network = network
        
        self.id = id
        self.snapshotId = snapshotId
        self.ownerId = ownerId
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

        Task {
            try await network.execute(request, expecting: TracksResponse.self, success: { response in
                DispatchQueue.main.async { [weak self] in
                    let tracks = response.items.map { $0.track }

                    if shouldOverwrite {
                        self?.tracks = []
                        self?.areSaved = [:]
                    }
                    self?.tracks.append(contentsOf: tracks)
                    self?.currentOffset += response.items.count
                    for track in tracks {
                        self?.checkSavedTracks(by: track.id)
                    }
                }
            }, failure: { _ in })
        }
    }

    func refreshSongs() {
        currentOffset = 0
        fetchSongs(shouldOverwrite: true)
    }

    var shouldFetchMoreSongs: Bool {
        !tracks.isEmpty && currentOffset < total
    }
}

// MARK: - ContextMenuItem

struct ContextMenuItem: Identifiable {
    let id: Int
    let label: LocalizedStringResource
    let systemName: String
    let action: () -> Void
}

// MARK: - PlaylistViewModel + ContextMenuableTrack

extension PlaylistViewModel: ContextMenuableTrack {
    func addItemToPlaylist() {
        isShowingSheet.toggle()
    }

    func removeTrack(by id: String) {
        DispatchQueue.main.async { [weak self] in
            self?.tracks.removeAll(where: { $0.id == id })
            self?.areSaved.removeValue(forKey: id)
        }
    }

    func updateTrackStatus(for trackId: String, isSaved: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.areSaved[trackId] = isSaved
        }
    }
}
