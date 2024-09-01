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
                ForEach(viewModel.tracks) { track in
                    ListItemView(title: track.name, subtitle: track.artists.first?.name ?? "", url: track.album?.images.first?.url)
                        .onTapGesture {
                            guard track.preview_url != nil else {
                                return
                            }

                            PlayerViewModel.shared.play(track: track)
                        }
                }

                if viewModel.shouldFetchMoreSongs {
                    ProgressView().task {
                        viewModel.fetchSongs()
                    }
                }
            }
            .navigationTitle(viewModel.name)
            .task {
                viewModel.fetchSongs()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: Constants.height + Constants.padding)
        }
        .refreshable {
            viewModel.refreshSongs()
        }
    }
}
