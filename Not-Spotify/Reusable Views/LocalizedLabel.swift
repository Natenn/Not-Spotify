//
//  LocalizedLabel.swift
//  Not-Spotify
//
//  Created by Naten on 14.09.24.
//

import SwiftUI

struct LocalizedLabel: View {
    let title: LocalizedStringResource
    let systemName: String

    init(_ title: LocalizedStringResource, systemName: String) {
        self.title = title
        self.systemName = systemName
    }

    var body: some View {
        HStack {
            Text(title)
            Image(systemName: systemName)
        }
    }
}

#Preview {
    LocalizedLabel("Add to Playlist", systemName: "bookmark")
}
