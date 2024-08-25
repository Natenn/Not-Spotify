//
//  ItemType.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation

enum ItemType: String, Decodable {
    case album = "album"
    case playlist = "playlist"
    case track = "track"
    case artist = "artist"
    case genre = "GENRE"
}
