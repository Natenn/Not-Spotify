//
//  PlayerViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 01.09.24.
//

import Foundation
import AVFoundation
import Combine

class PlayerViewModel: ObservableObject {
    static let shared = PlayerViewModel()
    
    private init() {}
    
    private var cancellables = Set<AnyCancellable>()
    
    private var player: AVQueuePlayer?
    
    private var tracks = [Track]()
    
    private var index = -1
    
    @Published private(set) var currentItem: AVPlayerItem?
    
    var trackInfo: TrackInfo {
        guard !tracks.isEmpty else {
            return TrackInfo(name: "Play Something", artist: "😅😅", imageUrl: nil)
        }
        
        guard index >= 0, index < tracks.count else {
            return  TrackInfo(name: "Oops", artist: "😅😅", imageUrl: nil)
        }
        
        let track = tracks[index]
        
        return TrackInfo(
            name: track.name,
            artist: track.artists.first?.name ?? "😅😅",
            imageUrl: track.album?.images.first?.url
        )
    }
    
    var playButtonInfo: ButtonState {
        if isPlaying {
            return ButtonState(systemName: "pause.fill", isEnabled: true)
        } else if canPlay {
            return ButtonState(systemName: "play.fill", isEnabled: false)
        }
        
        return ButtonState(systemName: "play.fill", isEnabled: false)
    }
    
    var canPlay: Bool {
        tracks.isEmpty && player == nil
    }
    
    var isPlaying: Bool {
        player?.rate != 0.0 && player != nil && player?.currentItem != nil
    }
    
    func play(track: Track) {
        self.tracks = [track]
        
        guard let urlString = track.preview_url, let url = URL(string: urlString) else {
            return
        }
        
        player = AVQueuePlayer(items: [AVPlayerItem(url: url)])
        
        player?.publisher(for: \.currentItem)
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                self?.currentItem = item
                self?.index = 0
            }
            .store(in: &cancellables)
        
        player?.play()
    }
    
    func play(tracks: [Track]) {
        self.tracks = tracks.compactMap({
            guard  $0.preview_url != nil else {
                return nil
            }
            
            return $0
        })
        
        if self.tracks.isEmpty {
            // TODO: request new tracks
        }
        
        player = AVQueuePlayer(items: self.tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }
            
            return AVPlayerItem(url: url)
        }))
        
        player?.publisher(for: \.currentItem)
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                self?.currentItem = item
                self?.index += 1
            }
            .store(in: &cancellables)
        
        player?.play()
    }
}

struct TrackInfo {
    let name: String
    let artist: String
    let imageUrl: String?
}

struct ButtonState {
    let systemName: String
    let isEnabled: Bool
}
