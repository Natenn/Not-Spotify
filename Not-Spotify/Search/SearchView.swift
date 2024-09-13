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
                            ListItemView(title: .init(stringLiteral: track.name), subtitle: .init(stringLiteral: track.artist), url: track.imageUrl)
                                .onTapGesture {
                                    guard track.preview_url != nil else {
                                        return
                                    }

                                    PlayerViewModel.shared.play(track: track)
                                }
                                .contextMenu {
                                    ForEach(viewModel.contextMenuItems(for: track.id, and: track.uri)) { item in
                                        Button(action: item.action) {
                                            LocalizedLabel(item.label, systemName: item.systemName)
                                        }
                                    }
                                }
                                .sheet(isPresented: $viewModel.isShowingSheet) {
                                    OwnedPlaylistsView(trackUri: track.uri, parentPlaylistId: viewModel.id) {
                                        DispatchQueue.main.async {
                                            viewModel.isShowingSheet.toggle()
                                        }
                                    }
                                    .presentationDetents([.medium, .large])
                                }
                        case let .playlist(playlist):
                            PlaylistNavigationItemView(
                                id: playlist.id,
                                snapshotId: playlist.snapshot_id,
                                ownerId: playlist.ownerId,
                                name: .init(stringLiteral: playlist.name),
                                subtitle: playlist.subtitle,
                                total: playlist.total,
                                endpoint: Endpoint.playlistTracks(playlistId: playlist.id),
                                imageUrl: playlist.imageUrl
                            )
                            .contextMenu {
                                ForEach(viewModel.contextMenuItems(for: playlist.id)) { item in
                                    Button(action: item.action) {
                                        LocalizedLabel(item.label, systemName: item.systemName)
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
