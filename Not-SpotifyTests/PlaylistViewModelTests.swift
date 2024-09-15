//
//  PlaylistViewModelTests.swift
//  Not-SpotifyTests
//
//  Created by Naten on 15.09.24.
//

@testable import Not_Spotify
import SwiftNetwork
import XCTest

final class PlaylistViewModelTests: XCTestCase {
    func testInitialization() {
        let viewModel = PlaylistViewModel(network: MockNetwork(), id: "1", snapshotId: "snap1", ownerId: "owner1", name: "Test Playlist", total: 100, endpoint: "testEndpoint")

        XCTAssertEqual(viewModel.id, "1")
        XCTAssertEqual(viewModel.snapshotId, "snap1")
        XCTAssertEqual(viewModel.ownerId, "owner1")
        XCTAssertEqual(viewModel.name, "Test Playlist")
        XCTAssertEqual(viewModel.total, 100)
        XCTAssertEqual(viewModel.endpoint, "testEndpoint")
        XCTAssertTrue(viewModel.tracks.isEmpty)
        XCTAssertTrue(viewModel.areSaved.isEmpty)
        XCTAssertFalse(viewModel.isShowingSheet)
        XCTAssertEqual(viewModel.currentOffset, 0)
    }

    func testFetchSongs() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.mockResponse = MockData.mockFavourites
        mockNetwork.execution = {
            expectation.fulfill()
        }
        let viewModel = PlaylistViewModel(network: mockNetwork, id: "1", snapshotId: "snap1", ownerId: "owner1", name: "Test Playlist", total: 100, endpoint: "testEndpoint")

        viewModel.fetchSongs()
        await fulfillment(of: [expectation], timeout: 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.tracks.count, 1)
            XCTAssertEqual(viewModel.tracks[0].id, "0123456789")
        }
    }

    func testRefreshSongs() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.mockResponse = MockData.mockFavourites
        mockNetwork.execution = {
            expectation.fulfill()
        }
        let viewModel = PlaylistViewModel(network: mockNetwork, id: "1", snapshotId: "snap1", ownerId: "owner1", name: "Test Playlist", total: 100, endpoint: "testEndpoint")

        viewModel.fetchSongs()
        await fulfillment(of: [expectation], timeout: 2)

        viewModel.refreshSongs()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.tracks.count, 1)
            XCTAssertEqual(viewModel.tracks[0].id, "0123456789")
        }
    }

    func testShouldFetchMoreSongs() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockFavourites
        let viewModel = PlaylistViewModel(network: mockNetwork, id: "1", snapshotId: "snap1", ownerId: "owner1", name: "Test Playlist", total: 2, endpoint: "testEndpoint")

        viewModel.fetchSongs()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertFalse(viewModel.shouldFetchMoreSongs)
    }

    func testAddItemToPlaylist() {
        let viewModel = PlaylistViewModel(network: MockNetwork(), id: "1", snapshotId: "snap1", ownerId: "owner1", name: "Test Playlist", total: 2, endpoint: "testEndpoint")
        XCTAssertFalse(viewModel.isShowingSheet)
        viewModel.addItemToPlaylist()
        XCTAssertTrue(viewModel.isShowingSheet)
    }

    func testRemoveTrack() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockFavourites
        let viewModel = PlaylistViewModel(network: mockNetwork, id: "1", snapshotId: "snap1", ownerId: "owner1", name: "Test Playlist", total: 2, endpoint: "testEndpoint")
        
        viewModel.fetchSongs()
        await fulfillment(of: [expectation], timeout: 2)
        
        viewModel.areSaved = ["1": true]
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.tracks.count, 1)
            XCTAssertEqual(viewModel.tracks[0].id, "2")
            XCTAssertNil(viewModel.areSaved["1"])
        }
    }

    func testUpdateTrackStatus() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockFavourites
        let viewModel = PlaylistViewModel(network: mockNetwork, id: "1", snapshotId: "snap1", ownerId: "owner1", name: "Test Playlist", total: 2, endpoint: "testEndpoint")
        
        viewModel.fetchSongs()
        await fulfillment(of: [expectation], timeout: 2)
        
        viewModel.updateTrackStatus(for: "1", isSaved: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.areSaved["1"], true)
        }

        viewModel.updateTrackStatus(for: "1", isSaved: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.areSaved["1"], false)
        }
    }
}
