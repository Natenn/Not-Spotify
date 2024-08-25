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
                let totalTracks = playlist.tracks.total ?? 0
                var songCount = "\(totalTracks) song"
                if totalTracks != 1 {
                    songCount.append("s")
                }
                let subtitle = "\(playlist.owner.display_name ?? "") · \(songCount)"
                let imageUrl = playlist.images.first?.url

                return ListItemView(title: playlist.name, subtitle: subtitle, url: imageUrl)
            }
        }
    }
}

#Preview {
    LibraryView()
}
