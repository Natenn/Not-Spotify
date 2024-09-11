//
//  SearchView.swift
//  Not-Spotify
//
//  Created by Naten on 05.09.24.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem()]) {
                    ForEach(viewModel.searchResults) { searchResult in
                        switch searchResult {
                        case let .track(track):
                            ListItemView(title: track.name, subtitle: track.artist, url: track.imageUrl)
                                .onTapGesture {
                                    guard track.preview_url != nil else {
                                        return
                                    }

                                    PlayerViewModel.shared.play(track: track)
                                }
                                .contextMenu {
                                    ForEach(viewModel.contextMenuItems(for: track.id)) { item in
                                        Button(action: item.action) {
                                            Label(item.label, systemImage: item.systemName)
                                        }
                                    }
                                }
                        case let .playlist(playlist):
                            PlaylistNavigationItemView(
                                name: playlist.name,
                                subtitle: playlist.subtitle,
                                total: playlist.total,
                                endpoint: Endpoint.playlistTracks(playlistId: playlist.id),
                                imageUrl: playlist.imageUrl
                            )
                            .contextMenu {
                                ForEach(viewModel.contextMenuItems(playlistId: playlist.id)) { item in
                                    Button(action: item.action) {
                                        Label(item.label, systemImage: item.systemName)
                                    }
                                }
                            }
                        }
                    }

                    if viewModel.shouldFetchMoreItems {
                        ProgressView().task {
                            viewModel.fetchMoreItems()
                        }
                    }
                }
                .padding(Constants.largerPadding)
            }
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: Constants.height + Constants.padding)
            }
            .searchable(text: $viewModel.query, prompt: "Search Songs and Playlists")
            .onSubmit(of: .search) {
                viewModel.fetchItems()
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
