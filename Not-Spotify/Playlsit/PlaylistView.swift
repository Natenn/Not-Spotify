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
                    ListItemView(title: track.name, subtitle: track.artist, url: track.imageUrl)
                        .onTapGesture {
                            guard track.preview_url != nil else {
                                return
                            }

                            PlayerViewModel.shared.play(track: track)
                        }
                        .contextMenu {
                            ForEach(viewModel.contextMenuItems(for: track.id)) { item in
                                Button(action: item.action) {
                                    Label(item.label, systemImage: item.systemName)
                                }
                            }
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
