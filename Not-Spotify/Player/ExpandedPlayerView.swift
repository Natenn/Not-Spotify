//
//  ExpandedPlayerView.swift
//  Not-Spotify
//
//  Created by Naten on 03.09.24.
//

import SwiftUI

struct ExpandedPlayerView: View {
    @StateObject private var viewModel = PlayerViewModel.shared

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            VStack {
                let url = URL(string: viewModel.trackInfo.imageUrl)
                let size = min(geometry.size.width * 0.8, geometry.size.height * 0.4)

                if verticalSizeClass == .compact {
                    HStack {
                        Color.clear
                            .frame(width: .zero)
                        image(url: url, size: size)
                        controls
                    }
                } else {
                    VStack {
                        image(url: url, size: size)
                        controls
                    }
                }
            }
            .tint(.green)
            .padding()
        }
    }

    private func image(url: URL?, size: CGFloat) -> some View {
        ImageView(url: url, systemName: "waveform")
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: Constants.innerRadius))
            .padding()
    }

    private var controls: some View {
        VStack {
            Text(viewModel.trackInfo.name)
                .font(.system(size: 20).weight(.semibold))
            Text(viewModel.trackInfo.artist)
                .foregroundStyle(.secondary)
            Slider(
                value: self.$viewModel.currentProgress,
                in: 0...viewModel.trackDuration,
                onEditingChanged: { editing in
                    if editing {
                        viewModel.scrollState = .scrollStarted
                    } else {
                        viewModel.scrollState = .scrollEnded(viewModel.currentProgress)
                    }
                }
            )
            .padding()
            .disabled(!viewModel.canScroll)
            buttons
        }
    }

    private var buttons: some View {
        HStack {
            Group {
                Button(action: viewModel.toggleSavedTrack) {
                    Image(systemName: viewModel.likeButtonInfo.systemName)
                        .font(.system(size: Constants.magicNumber * 1.2))
                }
                Button(action: viewModel.playPrevious) {
                    Image(systemName: "backward.fill")
                }.disabled(!viewModel.canRewind)
                Button(action: viewModel.togglePlayback) {
                    Image(systemName: viewModel.playButtonInfo.systemName)
                        .font(.system(size: Constants.magicNumber * 1.5))
                }.disabled(!viewModel.playButtonInfo.isEnabled)
                Button(action: viewModel.playNext) {
                    Image(systemName: "forward.fill")
                }.disabled(!viewModel.hasNext)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.magicNumber * 2)
        }.font(.system(size: Constants.magicNumber))
    }
}

#Preview {
    ExpandedPlayerView()
}
