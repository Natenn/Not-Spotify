//
//  TabBarView.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import SwiftUI

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
    }
}

#Preview {
    TabBarView()
}
