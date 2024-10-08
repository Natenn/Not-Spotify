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
                    ListItemView(title: .init(stringLiteral: track.name), subtitle: .init(stringLiteral: track.artist), url: track.imageUrl)
                        .onTapGesture {
                            guard track.preview_url != nil else {
                                return
                            }

                            PlayerViewModel.shared.play(track: track)
                        }
                        .contextMenu {
                            ForEach(viewModel.contextMenuItems(for: track.id, and: track.uri)) { item in
                                Button(action: item.action) {
                                    LocalizedLabel(item.label, systemName: item.systemName)
                                }
                            }
                        }
                        .sheet(isPresented: $viewModel.isShowingSheet) {
                            OwnedPlaylistsView(trackUri: track.uri, parentPlaylistId: viewModel.id) {
                                DispatchQueue.main.async {
                                    viewModel.isShowingSheet.toggle()
                                }
                            }
                            .presentationDetents([.medium, .large])
                        }
                }

                if viewModel.shouldFetchMoreSongs {
                    ProgressView().task {
                        viewModel.fetchSongs()
                    }
                }
            }
            .padding(Constants.largerPadding)
            .navigationTitle(Text(viewModel.name))
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
    PlaylistView(viewModel: PlaylistViewModel(id: "", snapshotId: "", ownerId: "", name: "Playlist", total: 50, endpoint: ""))
}
