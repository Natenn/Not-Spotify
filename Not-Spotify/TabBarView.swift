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
                NavigationStack {
                    LibraryView().navigationTitle("Library")
                }
            }
            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    LibraryView().navigationTitle("Search")
                }
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
