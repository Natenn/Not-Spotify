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
                    let artist = track.artists.first?.name ?? ""
                    let imageUrl = track.album?.images.first?.url

                    ListItemView(title: track.name, subtitle: artist, url: imageUrl)
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
            .padding(Constants.largerPadding)
            .navigationTitle(viewModel.name)
            .toolbar {
                Button("Play") {
                    PlayerViewModel.shared.play(
                        tracks: viewModel.tracks,
                        from: viewModel
                    )
                }
            }
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

#Preview {
    PlaylistView(viewModel: PlaylistViewModel(name: "Playlist", total: 50, endpoint: ""))
}
