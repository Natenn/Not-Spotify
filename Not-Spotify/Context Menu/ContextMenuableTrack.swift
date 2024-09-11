//
//  ContextMenuableTrack.swift
//  Not-Spotify
//
//  Created by Naten on 11.09.24.
//

import Foundation
import SwiftNetwork

// MARK: - ContextMenuableTrack

protocol ContextMenuableTrack {
    var areSaved: [String: Bool] { get set }
    var endpoint: String { get }

    func contextMenuItems(for trackId: String) -> [ContextMenuItem]
    func checkSavedTracks(by id: String)
    func removeTrack(by id: String)
    func updateTrackStatus(for trackId: String, isSaved: Bool)
}

extension ContextMenuableTrack {
    func contextMenuItems(for trackId: String) -> [ContextMenuItem] {
        var items = [ContextMenuItem]()

        if areSaved[trackId] == true {
            items.append(ContextMenuItem(
                id: 0,
                label: "Remove from Favourites",
                systemName: "minus.circle",
                action: {
                    toggleSavedTrack(by: trackId)
                }
            ))
        } else {
            items.append(ContextMenuItem(
                id: 0,
                label: "Add to Favourites",
                systemName: "heart",
                action: {
                    toggleSavedTrack(by: trackId)
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

    func checkSavedTracks(by id: String) {
        let request = Request(
            endpoint: Endpoint.checkSavedTracks,
            query: [
                APIKeys.ids: id,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: [Bool].self, success: { response in
                DispatchQueue.main.async {
                    updateTrackStatus(for: id, isSaved: response.first ?? false)
                }
            })
        }
    }

    func toggleSavedTrack(by trackId: String) {
        let request = Request(
            endpoint: Endpoint.savedTracks,
            method: savedTracksMethod(for: trackId),
            body: [
                APIKeys.ids: [trackId],
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: EmptyResponse.self, success: { _ in
                if let isSaved = areSaved[trackId] {
                    updateTrackStatus(for: trackId, isSaved: !isSaved)
                    if endpoint == Endpoint.savedTracks {
                        removeTrack(by: trackId)
                    }
                }
            })
        }
    }

    private func savedTracksMethod(for trackId: String) -> HTTPMethod {
        guard let isSaved = areSaved[trackId] else {
            return endpoint == Endpoint.savedTracks ? .delete : .put
        }

        return isSaved ? .delete : .put
    }
}
