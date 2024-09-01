//
//  MiniPlayerView.swift
//  Not-Spotify
//
//  Created by Naten on 01.09.24.
//

import SwiftUI

struct MiniPlayerView: View {
    let title: String
    let subtitle: String
    var url: String?
    var systemName: String?

    var body: some View {
        RoundedRectangle(cornerRadius: Constants.outerRadius)
            .fill(.ultraThinMaterial)
            .frame(height: Constants.height)
            .overlay(alignment: .leading) {
                HStack {
                    ListItemView(title: title, subtitle: subtitle, systemName: "waveform", isFilled: false)
                    Group {
                        Button(action: {}) {
                            Image(systemName: "play.fill")
                                .font(.system(size: Constants.magicNumber))
                        }.disabled(true)
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
    MiniPlayerView(title: "Play Something", subtitle: "😅😅")
}
