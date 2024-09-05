//
//  PlaylistNavigationItemView.swift
//  Not-Spotify
//
//  Created by Naten on 05.09.24.
//

import SwiftUI

struct PlaylistNavigationItemView: View {
    let name: String
    let subtitle: String
    let total: Int
    let endpoint: String
    var imageUrl: String? = nil
    var systemName: String? = nil
    
    var body: some View {
        NavigationLink(destination:
            PlaylistView(
                viewModel: PlaylistViewModel(
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
    PlaylistNavigationItemView(name: "Playlist", subtitle: "Description", total: 50, endpoint: "", imageUrl: "", systemName: "heart.fill")
}
