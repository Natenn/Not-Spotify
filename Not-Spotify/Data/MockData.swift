//
//  MockData.swift
//  Not-Spotify
//
//  Created by Naten on 14.09.24.
//

import Foundation

struct MockData {
    static let mockPlaylists = PlaylistsResponse(
        href: "https://api.spotify.com/v1/users/spotify/playlists",
        limit: 20,
        next: "https://api.spotify.com/v1/users/spotify/playlists?offset=20&limit=20",
        offset: 0,
        previous: nil,
        total: 2,
        items: [
            SimplifiedPlaylistObject(
                collaborative: false,
                description: "This is a sample playlist description",
                external_urls: ExternalUrls(spotify: "https://open.spotify.com/playlist/37i9dQZF1DX5Ejj0EkURtP"),
                href: "https://api.spotify.com/v1/playlists/37i9dQZF1DX5Ejj0EkURtP",
                id: "37i9dQZF1DX5Ejj0EkURtP",
                images: [
                    ImageObject(
                        url: "https://i.scdn.co/image/ab67706f00000003e8e28219724c2423afa4d320",
                        height: 640,
                        width: 640
                    ),
                ],
                name: "Sample Playlist",
                owner: Owner(
                    id: "spotify",
                    display_name: "Spotify"
                ),
                public: true,
                snapshot_id: "MTYwNjg1NzI0MCwwMDAwMDA3NTAwMDAwMTc1ZjkzZTk1YjAwMDAwMDE2ZDkyOGE3Zjg0",
                tracks: Tracks(
                    href: "https://api.spotify.com/v1/playlists/37i9dQZF1DX5Ejj0EkURtP/tracks",
                    total: 50
                ),
                type: "playlist",
                uri: "spotify:playlist:37i9dQZF1DX5Ejj0EkURtP"
            ),
            SimplifiedPlaylistObject(
                collaborative: true,
                description: "Another sample playlist description",
                external_urls: ExternalUrls(spotify: "https://open.spotify.com/playlist/1234567890"),
                href: "https://api.spotify.com/v1/playlists/1234567890",
                id: "1234567890",
                images: [
                    ImageObject(
                        url: "https://i.scdn.co/image/ab67706f00000003e8e28219724c2423afa4d321",
                        height: 300,
                        width: 300
                    ),
                ],
                name: "Another Sample Playlist",
                owner: Owner(
                    id: "user123",
                    display_name: "Sample User"
                ),
                public: false,
                snapshot_id: "MTYwNjg1NzI0MCwwMDAwMDA3NTAwMDAwMTc1ZjkzZTk1YjAwMDAwMDE2ZDkyOGE3Zjg1",
                tracks: Tracks(
                    href: "https://api.spotify.com/v1/playlists/1234567890/tracks",
                    total: 25
                ),
                type: "playlist",
                uri: "spotify:playlist:1234567890"
            ),
        ]
    )
    
    static let mockFavourites = TracksResponse(
        href: "https://api.spotify.com/v1/me/tracks?offset=0&limit=20",
        limit: 20,
        next: "https://api.spotify.com/v1/me/tracks?offset=20&limit=20",
        offset: 0,
        previous: nil,
        total: 53,
        items: [
            SavedTrackObject(
                added_at: "2023-05-15T12:00:00Z",
                track: Track(
                    album: Album(
                        total_tracks: 12,
                        available_markets: ["US", "GB", "CA"],
                        external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1234567890"),
                        href: "https://api.spotify.com/v1/albums/1234567890",
                        id: "1234567890",
                        images: [
                            ImageObject(url: "https://i.scdn.co/image/ab67616d0000b273123456789", height: 640, width: 640),
                            ImageObject(url: "https://i.scdn.co/image/ab67616d00001e02123456789", height: 300, width: 300),
                        ],
                        name: "Sample Album",
                        release_date: "2023-01-01",
                        release_date_precision: .day,
                        type: "album",
                        uri: "spotify:album:1234567890",
                        genres: ["pop", "rock"],
                        label: "Sample Label",
                        popularity: 75,
                        artists: [
                            Artist(
                                genres: ["pop"],
                                href: "https://api.spotify.com/v1/artists/abcdefghij",
                                id: "abcdefghij",
                                images: [
                                    ImageObject(url: "https://i.scdn.co/image/ab6761610000e5ebabcdefghij", height: 640, width: 640),
                                ],
                                name: "Sample Artist",
                                popularity: 80,
                                type: "artist",
                                uri: "spotify:artist:abcdefghij"
                            ),
                        ]
                    ),
                    artists: [
                        Artist(
                            genres: ["pop"],
                            href: "https://api.spotify.com/v1/artists/abcdefghij",
                            id: "abcdefghij",
                            images: [
                                ImageObject(url: "https://i.scdn.co/image/ab6761610000e5ebabcdefghij", height: 640, width: 640),
                            ],
                            name: "Sample Artist",
                            popularity: 80,
                            type: "artist",
                            uri: "spotify:artist:abcdefghij"
                        ),
                    ],
                    external_urls: ExternalUrls(spotify: "https://open.spotify.com/track/0123456789"),
                    href: "https://api.spotify.com/v1/tracks/0123456789",
                    id: "0123456789",
                    is_playable: true,
                    name: "Sample Track",
                    popularity: 70,
                    preview_url: "https://p.scdn.co/mp3-preview/0123456789abcdef",
                    track_number: 1,
                    type: "track",
                    uri: "spotify:track:0123456789"
                )
            ),
        ]
    )
}
