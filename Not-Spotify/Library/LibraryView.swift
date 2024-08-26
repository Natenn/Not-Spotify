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
        }.onAppear {
            viewModel.fetchPlaylists()
            viewModel.fetchFavourites()
        }
    }

    private var favourites: some View {
        ListItemView(title: "Favourites", subtitle: "\(viewModel.favouriteTracksCount ?? 0) favourite songs", systemName: "heart.fill")
    }

    private var playlists: some View {
        LazyVGrid(columns: [GridItem()]) {
            ForEach(viewModel.playlists ?? []) { playlist in
                ListItemView(title: playlist.name, subtitle: playlist.subtitle, url: playlist.imageUrl)
            }
        }
    }
}

#Preview {
    LibraryView()
}
