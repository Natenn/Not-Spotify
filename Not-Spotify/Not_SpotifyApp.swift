//
//  Not_SpotifyApp.swift
//  Not-Spotify
//
//  Created by Naten on 21.08.24.
//

import SwiftUI

@main
struct Not_SpotifyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.green)
                .onAppear {
                    Network.shared.configureDefaultRequest()
                }
        }
    }
}
