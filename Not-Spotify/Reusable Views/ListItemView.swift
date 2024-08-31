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

    private let outerRadius = CGFloat(16)
    private let height = CGFloat(80)
    private let imageSize = CGFloat(64)
    private let innerRadius = CGFloat(8)
    private let padding = CGFloat(8)

    var body: some View {
        RoundedRectangle(cornerRadius: outerRadius)
            .fill(.quaternary)
            .frame(height: height)
            .overlay(alignment: .leading) {
                HStack {
                    image(from: URL(string: url ?? ""))
                        .foregroundColor(.green)
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: innerRadius))
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.system(size: 20).weight(.semibold))
                            .lineLimit(2)
                        Text(subtitle)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }.padding([.leading], padding)
                }.padding(padding)
            }
    }

    private func image(from url: URL?) -> some View {
        if let systemName {
            return AnyView(
                Image(systemName: systemName)
                    .foregroundColor(.green)
                    .font(.system(size: 44))
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
