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
    @Published var tracks = [Track]()

    @Published var areSaved = [String: Bool]()

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

        Task {
            try await Network.shared.execute(request, expecting: TracksResponse.self, success: { response in
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
            })
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
    let label: String
    let systemName: String
    let action: () -> Void
}

extension PlaylistViewModel {
    func contextMenuItems(for trackId: String) -> [ContextMenuItem] {
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
            action: { /*TODO: Implement*/ }
        ))

        return items
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

    private func toggleSavedTrack(by trackId: String) {
        let request = Request(
            endpoint: Endpoint.savedTracks,
            method: savedTracksMethod(for: trackId),
            body: [
                APIKeys.ids: [trackId],
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: EmptyResponse.self)
            DispatchQueue.main.async { [weak self] in
                self?.areSaved[trackId]?.toggle()
                if self?.endpoint == Endpoint.savedTracks {
                    self?.tracks.removeAll(where: { $0.id == trackId })
                    self?.areSaved.removeValue(forKey: trackId)
                }
            }
        }
    }

    private func savedTracksMethod(for trackId: String) -> HTTPMethod {
        guard let isSaved = areSaved[trackId] else {
            return endpoint == Endpoint.savedTracks ? .delete : .put
        }

        if isSaved {
            return .delete
        }

        return .put
    }
}
