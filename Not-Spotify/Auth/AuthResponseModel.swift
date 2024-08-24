//
//  AuthResponseModel.swift
//  Not-Spotify
//
//  Created by Naten on 24.08.24.
//

import Foundation

struct AuthResponse: Decodable {
    let access_token: String
    let token_type: String
    let scope: String?
    let expires_in: Int
    let refresh_token: String?
}
