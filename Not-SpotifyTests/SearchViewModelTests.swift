//
//  SearchViewModelTests.swift
//  Not-SpotifyTests
//
//  Created by Naten on 15.09.24.
//

@testable import Not_Spotify
import SwiftNetwork
import XCTest

class SearchViewModelTests: XCTestCase {
    func testInitialState() {
        let viewModel = SearchViewModel(network: MockNetwork())

        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertTrue(viewModel.areSaved.isEmpty)
        XCTAssertTrue(viewModel.areCollected.isEmpty)
        XCTAssertFalse(viewModel.isShowingSheet)
        XCTAssertTrue(viewModel.query.isEmpty)
    }

    func testFetchItems() async {
        let expectation = XCTestExpectation()
        let mockNetwork = MockNetwork()
        mockNetwork.mockResponse = MockData.mockSearchResponse
        mockNetwork.execution = {
            expectation.fulfill()
        }
        let viewModel = SearchViewModel(network: mockNetwork)
        viewModel.query = "hello"

        viewModel.fetchItems()
        await fulfillment(of: [expectation], timeout: 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.searchResults.count, 2)
        }
    }
}
