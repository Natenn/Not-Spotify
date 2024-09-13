//
//  OwnedPlaylistsView.swift
//  Not-Spotify
//
//  Created by Naten on 11.09.24.
//

import SwiftUI

struct OwnedPlaylistsView: View {
    @StateObject private var viewModel = OwnedPlaylistsViewModel()

    private let trackUri: String
    private var parentPlaylistId: String = ""
    private let completion: () -> Void

    init(trackUri: String, parentPlaylistId: String, completion: @escaping () -> Void) {
        self.trackUri = trackUri
        self.parentPlaylistId = parentPlaylistId
        self.completion = completion
    }

    var body: some View {
        ScrollView {
            Group {
                LazyVGrid(columns: [GridItem()]) {
                    ForEach(viewModel.playlists) { playlist in
                        Button(action: {
                            viewModel.addItem(with: trackUri, to: playlist.id) {
                                completion()
                            }
                        }) {
                            ListItemView(
                                title: .init(stringLiteral: playlist.name),
                                subtitle: playlist.subtitle,
                                url: playlist.imageUrl,
                                systemName: "music.note.list"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                if viewModel.shouldFetchMorePlaylists {
                    ProgressView().task {
                        viewModel.getOwnedPlaylists(from: parentPlaylistId)
                    }
                }
            }
            .padding(Constants.largerPadding)
            .padding(.top, Constants.largerPadding)
        }.task {
            viewModel.getOwnedPlaylists(from: parentPlaylistId)
        }
    }
}

#Preview {
    OwnedPlaylistsView(trackUri: "", parentPlaylistId: "", completion: {})
}
