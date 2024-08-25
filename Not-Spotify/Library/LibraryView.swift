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
            favourites

            LazyVGrid(columns: [GridItem()]) {
                ForEach(viewModel.playlists ?? []) { playlist in
                    let totalTracks = playlist.tracks.total ?? 0
                    var songCount: String = "\(totalTracks) song"
                    if totalTracks != 1 {
                        songCount.append("s")
                    }
                    let subtitle = "\(playlist.owner.display_name ?? "") · \(songCount)"
                    let imageUrl = playlist.images.first?.url
                    
                    return ListItemView(title: playlist.name, subtitle: subtitle, url: imageUrl)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .padding(12)
        .onAppear {
            viewModel.fetchPlaylists()
        }
    }

    private var favourites: some View {
        ListItemView(title: "Favourites", subtitle: "\(1) favourite songs", systemName: "heart.fill")
    }
}

#Preview {
    LibraryView()
}
