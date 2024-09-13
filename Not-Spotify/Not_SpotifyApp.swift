//
//  Not_SpotifyApp.swift
//  Not-Spotify
//
//  Created by Naten on 21.08.24.
//

import SwiftUI

@main
struct Not_SpotifyApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthorised {
                ContentView()
                    .environmentObject(authManager)
            } else {
                AuthWebView(viewModel: AuthViewModel())
                    .environmentObject(authManager)
                    .ignoresSafeArea()
            }
        }
    }
}
