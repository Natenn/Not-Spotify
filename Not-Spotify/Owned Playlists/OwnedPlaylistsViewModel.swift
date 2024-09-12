//
//  OwnedPlaylistsViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 11.09.24.
//

import Foundation
import SwiftNetwork

final class OwnedPlaylistsViewModel: ObservableObject {
    @Published private(set) var playlists = [SimplifiedPlaylistObject]()
    @Published var isShowingSheet = false

    private var total = 0
    private let offset = 20
    private var currentOffset = 0

    var shouldFetchMorePlaylists: Bool {
        !playlists.isEmpty && currentOffset < total
    }

    func getOwnedPlaylists(from parentPlaylistId: String) {
        let request = Request(
            endpoint: Endpoint.savedPlaylists,
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        Task {
            try await Network.shared.execute(
                request,
                expecting: PlaylistsResponse.self,
                success: { [weak self] response in
                    self?.currentOffset += response.items.count
                    self?.total = response.total
                    let ownedPlaylists = response.items.filter {
                        $0.owner.id == AuthManager.shared.userId && $0.id != parentPlaylistId
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?.playlists.append(contentsOf: ownedPlaylists)
                    }
                }
            )
        }
    }

    func addItem(with trackUri: String, to playlistId: String, completion: @escaping () -> Void) {
        let request = Request(
            endpoint: Endpoint.playlistTracks(playlistId: playlistId),
            method: .post,
            body: [
                APIKeys.uris: [trackUri],
            ]
        )

        Task {
            try await Network.shared.execute(
                request,
                expecting: PlaylistSnapshotId.self,
                success: { _ in
                    completion()
                }
            )
        }
    }
}
