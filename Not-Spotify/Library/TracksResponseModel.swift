//
//  TracksResponseModel.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation

// MARK: - TracksResponse

struct TracksResponse: Decodable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [SavedTrackObject]
}

// MARK: - SavedTrackObject

struct SavedTrackObject: Decodable {
    let added_at: String
    let track: Track
}

// MARK: - Track

struct Track: Decodable {
    let album: Album?
    let artists: [Artist]
    let external_urls: ExternalUrls
    let href: String
    let id: String
    let is_playable: Bool?
    let name: String
    let popularity: Int?
    let preview_url: String?
    let track_number: Int
    let type: ItemType
    let uri: String
}

// MARK: - Album

struct Album: Decodable {
    let total_tracks: Int
    let available_markets: [String]
    let external_urls: ExternalUrls
    let href: String
    let id: String
    let images: [ImageObject]
    let name: String
    let release_date: String
    let release_date_precision: ReleaseDatePrecision
    let type: ItemType
    let uri: String
    let genres: [String]?
    let label: String?
    let popularity: Int?
    let artists: [Artist]
}

// MARK: - ReleaseDatePrecision

enum ReleaseDatePrecision: String, Decodable {
    case year
    case month
    case day
}

// MARK: - Artist

struct Artist: Decodable {
    let genres: [String]?
    let href: String
    let id: String
    let images: [ImageObject]?
    let name: String
    let popularity: Int?
    let type: ItemType
    let uri: String
}
