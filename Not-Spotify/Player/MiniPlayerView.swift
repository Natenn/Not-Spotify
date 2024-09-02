//
//  MiniPlayerView.swift
//  Not-Spotify
//
//  Created by Naten on 01.09.24.
//

import SwiftUI

struct MiniPlayerView: View {
    @StateObject private var viewModel = PlayerViewModel.shared

    var body: some View {
        RoundedRectangle(cornerRadius: Constants.outerRadius)
            .fill(.ultraThinMaterial)
            .frame(height: Constants.height)
            .overlay(alignment: .leading) {
                HStack {
                    ListItemView(
                        title: viewModel.trackInfo.name,
                        subtitle: viewModel.trackInfo.artist,
                        url: viewModel.trackInfo.imageUrl,
                        systemName: "waveform",
                        isFilled: false
                    )
                    Group {
                        Button(action: viewModel.togglePlayback) {
                            Image(systemName: viewModel.playButtonInfo.systemName)
                                .font(.system(size: Constants.magicNumber))
                        }.disabled(!viewModel.playButtonInfo.isEnabled)
                        Button(action: {}) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: Constants.magicNumber * 0.66))
                        }.disabled(true)
                    }.padding(.trailing, Constants.padding * 2)
                }
            }
    }
}

#Preview {
    MiniPlayerView()
}
