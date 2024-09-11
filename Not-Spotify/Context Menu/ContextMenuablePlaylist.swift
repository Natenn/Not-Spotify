//
//  ContextMenuablePlaylist.swift
//  Not-Spotify
//
//  Created by Naten on 11.09.24.
//

import Foundation
import SwiftNetwork

// MARK: - ContextMenuablePlaylist

protocol ContextMenuablePlaylist {
    var areCollected: [String: Bool] { get set }

    func contextMenuItems(for playlistId: String) -> [ContextMenuItem]
    func checkFollowedPlaylists(by id: String)
    func updatePlaylistStatus(for playlistId: String, isCollected: Bool)
}

extension ContextMenuablePlaylist {
    func contextMenuItems(playlistId: String) -> [ContextMenuItem] {
        var items = [ContextMenuItem]()

        if areCollected[playlistId] == true {
            items.append(ContextMenuItem(
                id: 0,
                label: "Remove from Library",
                systemName: "bookmark.slash",
                action: {
                    toggleSavedPlaylist(by: playlistId)
                }
            ))
        } else {
            items.append(ContextMenuItem(
                id: 0,
                label: "Add to Library",
                systemName: "bookmark",
                action: {
                    toggleSavedPlaylist(by: playlistId)
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
                if let isCollected = areCollected[playlistId] {
                    updatePlaylistStatus(for: playlistId, isCollected: !isCollected)
                }
            })
        }
    }

    func checkFollowedPlaylists(by id: String) {
        let request = Request(
            endpoint: Endpoint.playlistFollowersContains(playlistId: id),
            query: [
                APIKeys.playlistId: id,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: [Bool].self, success: { response in
                updatePlaylistStatus(for: id, isCollected: response.first ?? false)
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
