//
//  OwnedPlaylistsViewModelTests.swift
//  Not-SpotifyTests
//
//  Created by Naten on 15.09.24.
//

@testable import Not_Spotify
import SwiftNetwork
import XCTest

class OwnedPlaylistsViewModelTests: XCTestCase {
    func testInitialState() {
        let viewModel = OwnedPlaylistsViewModel(network: MockNetwork())
        
        XCTAssertTrue(viewModel.playlists.isEmpty)
        XCTAssertFalse(viewModel.isShowingSheet)
        XCTAssertFalse(viewModel.shouldFetchMorePlaylists)
    }

    func testGetOwnedPlaylists() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockPlaylists
        let viewModel = OwnedPlaylistsViewModel(network: mockNetwork)

        viewModel.getOwnedPlaylists(from: "parentPlaylistId")
        await fulfillment(of: [expectation], timeout: 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.playlists.count, 1)
            XCTAssertEqual(viewModel.playlists[0].id, "37i9dQZF1DX5Ejj0EkURtP")
        }
    }

    func testShouldFetchMorePlaylists() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockPlaylists
        let viewModel = OwnedPlaylistsViewModel(network: mockNetwork)
        
        viewModel.getOwnedPlaylists(from: "parentPlaylistId")
        await fulfillment(of: [expectation], timeout: 2)
        
        XCTAssertFalse(viewModel.shouldFetchMorePlaylists)
    }

    func testAddItem() async {
        var expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = MockData.mockPlaylists
        let viewModel = OwnedPlaylistsViewModel(network: mockNetwork)
        
        viewModel.getOwnedPlaylists(from: "parentPlaylistId")
        await fulfillment(of: [expectation], timeout: 2)
        
        
        expectation = XCTestExpectation()
        mockNetwork.execution = {
            expectation.fulfill()
        }
        mockNetwork.mockResponse = PlaylistSnapshotId(snapshot_id: "newSnapshotId")

        viewModel.addItem(with: "trackUri", to: "playlistId") {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2)
        
        XCTAssertFalse(viewModel.isShowingSheet)
    }
}
