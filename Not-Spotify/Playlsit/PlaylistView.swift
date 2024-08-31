//
//  PlaylistView.swift
//  Not-Spotify
//
//  Created by Naten on 26.08.24.
//

import SwiftUI

struct PlaylistView: View {
    @StateObject var viewModel: PlaylistViewModel

    var playlist: SimplifiedPlaylistObject?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem()]) {
                ForEach(viewModel.tracks ?? []) { track in
                    ListItemView(title: track.name, subtitle: track.artists.first?.name ?? "", url: track.album?.images.first?.url)
                }
            }
            .navigationTitle(playlist?.name ?? "")
            .task {
                viewModel.fetchSongs()
            }
        }
    }
}

// #Preview {
//    PlaylistView()
// }
