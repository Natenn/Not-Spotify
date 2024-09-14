//
//  LibraryViewModelTests.swift
//  Not-SpotifyTests
//
//  Created by Naten on 21.08.24.
//

@testable import Not_Spotify
import SwiftNetwork
import XCTest

final class LibraryViewModelTests: XCTestCase {
    func testFetchPlaylists() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockPlaylists
        let viewModel = LibraryViewModel(network: mockNetwork)

        viewModel.fetchPlaylists()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(viewModel.playlists.count, 2)
        XCTAssertEqual(viewModel.playlists.first?.id, "37i9dQZF1DX5Ejj0EkURtP")
        XCTAssertEqual(viewModel.playlists.first?.name, "Sample Playlist")
    }

    func testFetchFavourites() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockFavourites
        let viewModel = LibraryViewModel(network: mockNetwork)

        viewModel.fetchFavourites()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(viewModel.tracks.count, 1)
        XCTAssertEqual(viewModel.tracks.first?.track.id, "0123456789")
        XCTAssertEqual(viewModel.tracks.first?.track.name, "Sample Track")
        XCTAssertEqual(viewModel.favouriteTracksCount, 53)
    }

    func testUnfollowPlaylist() async {
        var expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockPlaylists
        let viewModel = LibraryViewModel(network: mockNetwork)

        viewModel.fetchPlaylists()
        await fulfillment(of: [expectation], timeout: 2)

        expectation = XCTestExpectation()
        mockNetwork.mockResponse = EmptyResponse(data: Data())
        let playlistId = "37i9dQZF1DX5Ejj0EkURtP"

        viewModel.unfollowPlaylist(playlistId: playlistId)
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(viewModel.playlists.count, 1)
        XCTAssertEqual(viewModel.playlists.first?.id, "1234567890")
    }

    func testIsDisabled() {
        let viewModel = LibraryViewModel()

        viewModel.name = ""
        XCTAssertTrue(viewModel.isDisabled)
    }

    func testIsNotDisabled() {
        let viewModel = LibraryViewModel()

        viewModel.name = "Test"
        XCTAssertFalse(viewModel.isDisabled)
    }

    func testShouldNotFetchMorePlaylists() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockPlaylists
        let viewModel = LibraryViewModel(network: mockNetwork)

        viewModel.fetchPlaylists()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertFalse(viewModel.shouldFetchMorePlaylists)
    }

    func testShouldFetchMorePlaylists() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = PlaylistsResponse(
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
            ]
        )
        let viewModel = LibraryViewModel(network: mockNetwork)

        viewModel.fetchPlaylists()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertTrue(viewModel.shouldFetchMorePlaylists)
    }

    func testrefreshPlaylists() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockPlaylists
        let viewModel = LibraryViewModel(network: mockNetwork)

        viewModel.fetchPlaylists()
        await fulfillment(of: [expectation], timeout: 2)

        let playlists = viewModel.playlists
        
        viewModel.refreshPlaylists()
        
        let refreshedPlaylists = viewModel.playlists

        XCTAssertEqual(playlists.count, refreshedPlaylists.count)
    }
}
