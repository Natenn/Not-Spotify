//
//  TabBarView.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import SwiftUI

// MARK: - TabBarView

struct TabBarView: View {
    var body: some View {
        TabView {
            Tab("Library", systemImage: "books.vertical") {
                LibraryView()
            }
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            MiniPlayerView()
                .padding([.top, .bottom], Constants.padding)
                .offset(y: -tabBatHeight)
        }
    }

    private var tabBatHeight: CGFloat {
        UITabBarController().tabBar.frame.size.height
    }
}

#Preview {
    TabBarView()
}
