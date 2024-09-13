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
            .environment(\.locale, .init(identifier: settingsViewModel.locale.rawValue))
    }

    private var currentLocale: Locale {
        let locale = settingsViewModel.locale
        switch locale {
        case .system:
            return .init(identifier: Locale.current.language.languageCode?.identifier ?? "en")
        default:
            return .init(identifier: locale.rawValue)
        }
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
