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
        _locale = Published(initialValue: Locales(rawValue: UserDefaults.standard.string(forKey: "locale") ?? Locales.system.rawValue) ?? .system)
    }

    @Published var colourScheme: ColourScheme {
        didSet {
            UserDefaults.standard.set(colourScheme.rawValue, forKey: "colourScheme")
        }
    }

    @Published var locale: Locales {
        didSet {
            UserDefaults.standard.set(locale.rawValue, forKey: "locale")
        }
    }

    var colourSchemes: [ColourScheme] {
        ColourScheme.allCases
    }

    var languages: [Locales] {
        Locales.allCases
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
    var title: LocalizedStringResource {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

// MARK: - Locales

enum Locales: String, Identifiable, CaseIterable {
    var id: Self { self }
    case system
    case en
    case ka
}

extension Locales {
    var title: LocalizedStringResource {
        switch self {
        case .system:
            return "System"
        case .en:
            return "English"
        case .ka:
            return "Georgian"
        }
    }
}
