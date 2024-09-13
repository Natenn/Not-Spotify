//
//  ListItemView.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import SwiftUI

struct ListItemView: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
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
                    ImageView(url: URL(string: url ?? ""), systemName: systemName)
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
}
