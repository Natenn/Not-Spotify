//
//  PlayerInfoModels.swift
//  Not-Spotify
//
//  Created by Naten on 03.09.24.
//

import Foundation

// MARK: - TrackInfo

struct TrackInfo: Identifiable {
    let id: String
    let name: LocalizedStringResource
    let artist: String
    let imageUrl: String
}

// MARK: - ButtonState

struct ButtonState {
    let systemName: String
    let isEnabled: Bool
}
