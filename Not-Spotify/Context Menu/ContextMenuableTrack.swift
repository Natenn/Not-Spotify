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
    var id: String { get }
    var snapshotId: String { get }
    var ownerId: String { get }
    var endpoint: String { get }

    func contextMenuItems(for trackId: String, and trackUri: String) -> [ContextMenuItem]
    func checkSavedTracks(by id: String)
    func removeTrack(by id: String)
    func updateTrackStatus(for trackId: String, isSaved: Bool)
    func addItemToPlaylist()
}

extension ContextMenuableTrack {
    func contextMenuItems(for trackId: String, and trackUri: String) -> [ContextMenuItem] {
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
            action: {
                addItemToPlaylist()
            }
        ))

        if !id.isEmpty, !snapshotId.isEmpty, ownerId == AuthManager.shared.userId {
            items.append(ContextMenuItem(
                id: 2,
                label: "Remove from Playlist",
                systemName: "bookmark.slash",
                action: {
                    removeTrackFromPlaylist(by: trackId, and: trackUri)
                }
            ))
        }

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

    private func removeTrackFromPlaylist(by trackId: String, and trackUri: String) {
        let request = Request(
            endpoint: Endpoint.playlistTracks(playlistId: id),
            method: .delete,
            body: [
                APIKeys.tracks: [
                    [
                        APIKeys.uri: trackUri,
                    ],
                ],
                APIKeys.snapshotId: snapshotId,
            ]
        )

        Task {
            try await Network.shared.execute(
                request,
                expecting: PlaylistSnapshotId.self,
                success: { _ in
                    removeTrack(by: trackId)
                }
            )
        }
    }
}
