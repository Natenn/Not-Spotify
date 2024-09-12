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
            .toolbar {
                Button(action: { viewModel.isShowingSheet.toggle() }) {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $viewModel.isShowingSheet) {
                    createPlaylistForm
                        .presentationDetents([.medium, .medium])
                }
            }
        }
    }

    private var createPlaylistForm: some View {
        return Form {
            Section {
                TextField("Name", text: $viewModel.name)
                TextField("Description", text: $viewModel.description)
            }
            Button(action: viewModel.createPlaylist) {
                Text("Crate")
            }.disabled(viewModel.isDisabled)
        }
    }

    private var favourites: some View {
        PlaylistNavigationItemView(
            id: "",
            snapshotId: "",
            ownerId: "",
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
                        id: playlist.id,
                        snapshotId: playlist.snapshot_id,
                        ownerId: playlist.ownerId,
                        name: playlist.name,
                        subtitle: playlist.subtitle,
                        total: playlist.total,
                        endpoint: Endpoint.playlistTracks(playlistId: playlist.id),
                        imageUrl: playlist.imageUrl,
                        systemName: "music.note.list"
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
