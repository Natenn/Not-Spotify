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
    }

    private var favourites: some View {
        let favourites = "Favourites"
        
        return NavigationLink(destination:
            PlaylistView(
                viewModel: PlaylistViewModel(
                    name: favourites,
                    total: viewModel.favouriteTracksCount,
                    endpoint: Endpoint.savedTracks
                )
            )
        ) {
            ListItemView(
                title: favourites,
                subtitle: "\(viewModel.favouriteTracksCount) favourite songs",
                systemName: "heart.fill"
            )
        }.buttonStyle(PlainButtonStyle())
    }

    private var playlists: some View {
        Group {
            LazyVGrid(columns: [GridItem()]) {
                ForEach(viewModel.playlists) { playlist in
                    NavigationLink(destination:
                        PlaylistView(
                            viewModel: PlaylistViewModel(
                                name: playlist.name,
                                total: playlist.tracks.total ?? 0,
                                endpoint: Endpoint.playlistTracks(playlistId: playlist.id)
                            )
                        )
                    ) {
                        ListItemView(title: playlist.name, subtitle: playlist.subtitle, url: playlist.imageUrl)
                    }.buttonStyle(PlainButtonStyle())
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
