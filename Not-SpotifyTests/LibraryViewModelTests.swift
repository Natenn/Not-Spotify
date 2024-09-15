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
        XCTAssertEqual(viewModel.favouriteTracksCount, 3)
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
        mockNetwork.mockResponse = MockData.mockPlaylistResponse
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
