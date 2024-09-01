//
//  ListItemView.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import SwiftUI

struct ListItemView: View {
    let title: String
    let subtitle: String
    var url: String?
    var systemName: String?
    var isFilled: Bool = true

    var body: some View {
        RoundedRectangle(cornerRadius: Constants.outerRadius)
            .fill(.quaternary)
            .opacity(isFilled ? 1 : 0)
            .frame(height: Constants.height)
            .overlay(alignment: .leading) {
                HStack {
                    image(from: URL(string: url ?? ""))
                        .foregroundColor(.green)
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.innerRadius))
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.system(size: 20).weight(.semibold))
                            .lineLimit(2)
                        Text(subtitle)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }.padding(Constants.padding)
            }
    }

    private func image(from url: URL?) -> some View {
        if let systemName {
            return AnyView(
                Image(systemName: systemName)
                    .foregroundColor(.green)
                    .font(.system(size: Constants.magicNumber))
            )
        }

        return AnyView(
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
        )
    }
}
