//
//  SettingsViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 13.09.24.
//

import Foundation

// MARK: - SettingsViewModel

final class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()

    private init() {
        _colourScheme = Published(initialValue: ColourScheme(rawValue: UserDefaults.standard.integer(forKey: "colourScheme")) ?? .system)
    }

    @Published var colourScheme: ColourScheme {
        didSet {
            UserDefaults.standard.set(colourScheme.rawValue, forKey: "colourScheme")
        }
    }

    var colourSchemes: [ColourScheme] {
        ColourScheme.allCases
    }
}

// MARK: - ColourScheme

enum ColourScheme: Int, Identifiable, CaseIterable {
    var id: Self { self }
    case system
    case light
    case dark
}

extension ColourScheme {
    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}
