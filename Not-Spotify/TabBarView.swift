//
//  TabBarView.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        return TabView {
//            Tab("Home", systemImage: "house") {
//                NavigationStack {
//                    LibraryView().navigationTitle("Home")
//                }
//            }
//            Tab("Search", systemImage: "magnifyingglass") {
//                NavigationStack {
//                    LibraryView().navigationTitle("Search")
//                }
//            }
            Tab("Library", systemImage: "books.vertical") {
                NavigationStack {
                    LibraryView().navigationTitle("Library")
                }
            }
        }
    }
}

#Preview {
    TabBarView()
}
