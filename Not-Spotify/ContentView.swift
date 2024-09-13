//
//  ContentView.swift
//  Not-Spotify
//
//  Created by Naten on 21.08.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settingsViewModel = SettingsViewModel.shared

    var body: some View {
        TabBarView()
            .task {
                if AuthManager.shared.userId.isEmpty {
                    AuthManager.shared.getUserId()
                }
                Network.shared.configureDefaultRequest()
            }
            .accentColor(.green)
            .preferredColorScheme(preferredTheme)
    }

    private var preferredTheme: ColorScheme? {
        switch settingsViewModel.colourScheme {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return .none
        }
    }
}

#Preview {
    ContentView()
}
