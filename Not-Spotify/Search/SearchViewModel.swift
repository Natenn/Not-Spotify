//
//  SearchViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 05.09.24.
//

import Foundation
import SwiftNetwork

// MARK: - SearchViewModel

final class SearchViewModel: ObservableObject {
    @Published var searchResults = [SearchResult]()

    @Published var query: String = ""

    private let offset = 10
    private var currentOffset = 0

    func fetchItems(shouldOverwrite: Bool = true) {
        guard !query.isEmpty else {
            return
        }

        let request = Request(
            endpoint: Endpoint.search,
            query: [
                APIKeys.query: query.queryString,
                APIKeys.type: APIConstants.searchedTypes,
                APIKeys.limit: offset,
                APIKeys.offset: shouldOverwrite ? 0 : currentOffset,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: SearchResponseModel.self, success: { response in
                DispatchQueue.main.async { [weak self] in
                    if shouldOverwrite {
                        self?.searchResults = []
                    }

                    self?.searchResults.append(contentsOf: response.tracks.items.compactMap {
                        .track(track: $0)
                    })
                    self?.searchResults.append(contentsOf: response.playlists.items.compactMap {
                        .playlist(playlist: $0)
                    })

                    self?.currentOffset += response.playlists.items.count + response.tracks.items.count
                }
            })
        }
    }

    func fetchMoreItems() {
        fetchItems(shouldOverwrite: false)
    }

    var shouldFetchMoreItems: Bool {
        !searchResults.isEmpty && !query.isEmpty
    }
}

// MARK: - Extension

extension String {
    var queryString: String {
        replacingOccurrences(of: " ", with: "%20")
    }
}
