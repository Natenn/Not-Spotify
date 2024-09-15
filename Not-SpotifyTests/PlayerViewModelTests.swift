//
//  PlayerViewModelTests.swift
//  Not-SpotifyTests
//
//  Created by Naten on 15.09.24.
//

@testable import Not_Spotify
import SwiftNetwork
import XCTest

final class PlayerViewModelTests: XCTestCase {
    func testInitialState() {
        let viewModel = PlayerViewModel.shared

        XCTAssertNil(viewModel.currentItem)
        XCTAssertNil(viewModel.rate)
        XCTAssertEqual(viewModel.currentProgress, 0)
        XCTAssertFalse(viewModel.isSaved)
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertFalse(viewModel.canPlay)
        XCTAssertFalse(viewModel.canReplay)
        XCTAssertFalse(viewModel.hasTracks)
        XCTAssertFalse(viewModel.hasNext)
        XCTAssertFalse(viewModel.canRewind)
    }

    func testPlayTrack() {
        let viewModel = PlayerViewModel.shared

        let mockTrack = MockData.mockTrack

        viewModel.play(track: mockTrack)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(viewModel.currentItem)
            XCTAssertTrue(viewModel.isPlaying)
            XCTAssertTrue(viewModel.canPlay)
            XCTAssertTrue(viewModel.hasTracks)
            XCTAssertFalse(viewModel.hasNext)
        }
    }

    func testTogglePlayback() {
        let viewModel = PlayerViewModel.shared
        let mockTrack = MockData.mockTrack
        viewModel.play(track: mockTrack)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.togglePlayback()
            XCTAssertFalse(viewModel.isPlaying)

            viewModel.togglePlayback()
            XCTAssertTrue(viewModel.isPlaying)
        }
    }

    func testSeek() {
        let viewModel = PlayerViewModel.shared
        let mockTrack = MockData.mockTrack

        viewModel.play(track: mockTrack)
        viewModel.seek(to: 10.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.currentTime, 10.0, accuracy: 0.1)
        }
    }

    func testToggleSavedTrack() {
        let viewModel = PlayerViewModel.shared
        let mockTrack = MockData.mockTrack

        viewModel.play(track: mockTrack)

        XCTAssertFalse(viewModel.isSaved)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.toggleSavedTrack()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssert(viewModel.isSaved == true)
        }
    }

    func testPlayButtonInfo() {
        let viewModel = PlayerViewModel.shared

        viewModel.play(track: MockData.mockTrack)
        XCTAssertEqual(viewModel.playButtonInfo.systemName, "pause.fill")
        XCTAssertTrue(viewModel.playButtonInfo.isEnabled)

        viewModel.togglePlayback()
        viewModel.seek(to: viewModel.trackDuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.playButtonInfo.systemName, "memories")
            XCTAssertTrue(viewModel.playButtonInfo.isEnabled)
        }

        viewModel.seek(to: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.playButtonInfo.systemName, "play.fill")
            XCTAssertTrue(viewModel.playButtonInfo.isEnabled)
        }
    }

    func testLikeButtonInfo() {
        let viewModel = PlayerViewModel.shared
        
        XCTAssertEqual(viewModel.likeButtonInfo.systemName, "heart")
        XCTAssertTrue(viewModel.likeButtonInfo.isEnabled)

        viewModel.play(track: MockData.mockTrack)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.toggleSavedTrack()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.likeButtonInfo.systemName, "heart.fill")
            XCTAssertTrue(viewModel.likeButtonInfo.isEnabled)
        }
    }
}
