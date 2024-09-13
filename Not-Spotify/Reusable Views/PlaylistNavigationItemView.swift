//
//  PlaylistNavigationItemView.swift
//  Not-Spotify
//
//  Created by Naten on 05.09.24.
//

import SwiftUI

struct PlaylistNavigationItemView: View {
    let id: String
    let snapshotId: String
    let ownerId: String
    let name: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let total: Int
    let endpoint: String
    var imageUrl: String? = nil
    var systemName: String? = nil

    var body: some View {
        NavigationLink(destination:
            PlaylistView(
                viewModel: PlaylistViewModel(
                    id: id,
                    snapshotId: snapshotId,
                    ownerId: ownerId,
                    name: name,
                    total: total,
                    endpoint: endpoint
                )
            )
        ) {
            ListItemView(title: name, subtitle: subtitle, url: imageUrl, systemName: systemName)
        }.buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlaylistNavigationItemView(id: "", snapshotId: "", ownerId: "", name: "Playlist", subtitle: "Description", total: 50, endpoint: "", imageUrl: "", systemName: "heart.fill")
}
