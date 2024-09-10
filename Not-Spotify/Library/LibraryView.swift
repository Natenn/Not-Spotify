//
//  LibraryView.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    favourites
                    playlists
                }.padding(Constants.largerPadding)
            }
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: Constants.height + Constants.padding)
            }
            .refreshable {
                viewModel.refreshPlaylists()
            }
            .task {
                if viewModel.playlists.isEmpty {
                    viewModel.fetchPlaylists()
                }
                if viewModel.tracks.isEmpty {
                    viewModel.fetchFavourites()
                }
            }
            .navigationTitle("Library")
        }
    }

    private var favourites: some View {
        PlaylistNavigationItemView(
            name: "Favourites",
            subtitle: "\(viewModel.favouriteTracksCount) favourite songs",
            total: viewModel.favouriteTracksCount,
            endpoint: Endpoint.savedTracks,
            systemName: "heart.fill"
        )
    }

    private var playlists: some View {
        Group {
            LazyVGrid(columns: [GridItem()]) {
                ForEach(viewModel.playlists) { playlist in
                    PlaylistNavigationItemView(
                        name: playlist.name,
                        subtitle: playlist.subtitle,
                        total: playlist.total,
                        endpoint: Endpoint.playlistTracks(playlistId: playlist.id),
                        imageUrl: playlist.imageUrl
                    )
                    .contextMenu {
                        Button(action: { viewModel.unfollowPlaylist(playlistId: playlist.id) }) {
                            Label("Remove from Library", systemImage: "bookmark.slash")
                        }
                    }
                }
            }

            if viewModel.shouldFetchMorePlaylists {
                ProgressView().task {
                    viewModel.fetchPlaylists()
                }
            }
        }
    }
}

#Preview {
    LibraryView()
}
