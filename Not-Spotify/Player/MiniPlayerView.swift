//
//  MiniPlayerView.swift
//  Not-Spotify
//
//  Created by Naten on 01.09.24.
//

import SwiftUI

struct MiniPlayerView: View {
    @StateObject private var viewModel = PlayerViewModel.shared

    @State var trackInfo: TrackInfo?

    var body: some View {
        let roundedRectangle = RoundedRectangle(cornerRadius: Constants.outerRadius)

        ZStack(alignment: .bottom) {
            roundedRectangle
                .fill(.ultraThinMaterial)
                .frame(height: Constants.height)

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
                    Button(action: viewModel.playNext) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: Constants.magicNumber * 0.66))
                    }.disabled(!viewModel.hasNext)
                }.padding(.trailing, Constants.padding * 2)
            }
            ProgressView(value: viewModel.progress).progressViewStyle(.linear)
        }
        .clipShape(roundedRectangle)
        .onTapGesture {
            self.trackInfo = viewModel.trackInfo
        }
        .sheet(item: $trackInfo) { _ in
            ExpandedPlayerView()
        }
    }
}

#Preview {
    MiniPlayerView()
}
