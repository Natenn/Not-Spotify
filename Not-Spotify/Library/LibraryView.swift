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
            }.padding(12)
        }.task {
            if viewModel.playlists == nil {
                viewModel.fetchPlaylists()
            }
            if viewModel.tracks == nil {
                viewModel.fetchFavourites()
            }
        }
    }

    private var favourites: some View {
//        NavigationLink(destination: PlaylistView(name: "Favourites")) {
        ListItemView(title: "Favourites", subtitle: "\(viewModel.favouriteTracksCount ?? 0) favourite songs", systemName: "heart.fill")
//        }.buttonStyle(PlainButtonStyle())
    }

    private var playlists: some View {
        LazyVGrid(columns: [GridItem()]) {
            ForEach(viewModel.playlists ?? []) { playlist in
                NavigationLink(destination: PlaylistView(viewModel: PlaylistViewModel(playlist: playlist), playlist: playlist)) {
                    ListItemView(title: playlist.name, subtitle: playlist.subtitle, url: playlist.imageUrl)
                }.buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    LibraryView()
}
