//
//  TracksResponse.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation

struct TracksResponse: Decodable {
    let href: String
    let total: Int?
}
