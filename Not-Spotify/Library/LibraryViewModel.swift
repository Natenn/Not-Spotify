//
//  LibraryViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation
import SwiftNetwork
import Combine

final class LibraryViewModel: ObservableObject {
    
    @Published var playlists: [SimplifiedPlaylistObject]?
    @Published var tracks: [SavedTrackObject]?
    @Published var favouriteTracksCount: Int?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let offset = 20
    private var currentOffset = 0

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
                self?.playlists = response.items
                self?.currentOffset += response.items.count
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
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
