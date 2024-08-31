//
//  Constants.swift
//  Not-Spotify
//
//  Created by Naten on 24.08.24.
//

import Foundation

// MARK: - UserDefaultsKeys

enum UserDefaultsKeys {
    static let accessToken = "access_token"
    static let refreshToken = "refresh_token"
    static let expirationDate = "expirationDate"
}

// MARK: - APICredentials

enum APICredentials {
    static let clientId = "66377121e2934741a7f8cea2af3da19f"
    static let clientSecret = "8fab170a7dee4b48a229b1407082bb6d"
}

// MARK: - Constants

enum Constants {
    static let redirectUri = "https://github.com/Natenn"
    static let contentType = "application/x-www-form-urlencoded"
}

// MARK: - BaseUrl

enum BaseUrl {
    static let authBaseUrl = "accounts.spotify.com"
    static let spotifyApiBaseUrl = "api.spotify.com"
}

// MARK: - Endpoint

enum Endpoint {
    static let authorize = "authorize"
    static let authToken = "api/token"
    static let savedPlaylists = "me/playlists"
    static let savedTracks = "me/tracks"
    static func playlistTracks(playlistId: String) -> String { "playlists/\(playlistId)/tracks" }
}

// MARK: - APIKeys

enum APIKeys {
    // MARK: Auth

    static let clientId = "client_id"
    static let responseType = "response_type"
    static let redirectUri = "redirect_uri"
    static let showDialog = "show_dialog"
    static let code = "code"
    static let scope = "scope"
    static let refreshToken = "refresh_token"
    static let authorizationCode = "authorization_code"
    static let grantType = "grant_type"
    static let authorization = "Authorization"
    static let contentType = "Content-Type"

    // MARK: General

    static let limit = "limit"
    static let offset = "offset"
}

// MARK: - UserScopes

enum UserScopes {
    static let ugcImageUpload = "ugc-image-upload"
    static let userReadPlaybackState = "user-read-playback-state"
    static let userModifyPlaybackState = "user-modify-playback-state"
    static let userReadCurrentlyPlaying = "user-read-currently-playing"
    static let appRemoteControl = "app-remote-control"
    static let streaming = "streaming"
    static let playlistReadPrivate = "playlist-read-private"
    static let playlistReadCollaborative = "playlist-read-collaborative"
    static let playlistModifyPrivate = "playlist-modify-private"
    static let playlistModifyPublic = "playlist-modify-public"
    static let userFollowModify = "user-follow-modify"
    static let userFollowRead = "user-follow-read"
    static let userReadPlaybackPosition = "user-read-playback-position"
    static let userTopRead = "user-top-read"
    static let userReadRecentlyPlayed = "user-read-recently-played"
    static let userLibraryModify = "user-library-modify"
    static let userLibraryRead = "user-library-read"
    static let userReadEmail = "user-read-email"
    static let userReadPrivate = "user-read-private"
}

extension UserScopes {
    static func compactUserScopes(_ scopes: [String]) -> String {
        scopes.compactMap { $0 }.joined(separator: "%20")
    }

    /// Return Every User Permission
    /// - Returns: Array of UserScopes
    static func getAllUserScopes() -> String {
        compactUserScopes([
            UserScopes.ugcImageUpload,
            UserScopes.userReadPlaybackState,
            UserScopes.userModifyPlaybackState,
            UserScopes.userReadCurrentlyPlaying,
            UserScopes.appRemoteControl,
            UserScopes.streaming,
            UserScopes.playlistReadPrivate,
            UserScopes.playlistReadCollaborative,
            UserScopes.playlistModifyPrivate,
            UserScopes.playlistModifyPublic,
            UserScopes.userFollowModify,
            UserScopes.userFollowRead,
            UserScopes.userReadPlaybackPosition,
            UserScopes.userTopRead,
            UserScopes.userReadRecentlyPlayed,
            UserScopes.userLibraryModify,
            UserScopes.userLibraryRead,
            UserScopes.userReadEmail,
            UserScopes.userReadPrivate,
        ])
    }
}
