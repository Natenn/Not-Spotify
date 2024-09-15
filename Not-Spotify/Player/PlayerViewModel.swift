//
//  PlayerViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 01.09.24.
//

import Combine
import MediaPlayer
import SwiftNetwork

// MARK: - PlayerViewModel

final class PlayerViewModel: ObservableObject {
    static let shared = PlayerViewModel()

    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    private var nowPlayingInfo = [String: Any]()

    private init() {
        registerTargetForRemoteCommands()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        } catch {
            print(error.localizedDescription)
        }
    }

    private var endpoint = ""
    private var currentOffset = 0
    private var total = 0

    private var cancellables = Set<AnyCancellable>()

    private var player: AVQueuePlayer?

    private var tracks = [Track]()

    private var index = -1
    private var offset = 20

    @Published private(set) var currentItem: AVPlayerItem?
    @Published private(set) var rate: Float?
    @Published var currentProgress: Float = 0
    @Published private(set) var isSaved: Bool = false

    var trackInfo: TrackInfo {
        guard !tracks.isEmpty else {
            return TrackInfo(id: "-1", name: "Play Something", artist: "😅😅", imageUrl: "")
        }

        guard index >= 0, index < tracks.count else {
            return TrackInfo(id: "-2", name: "Oops", artist: "😅😅", imageUrl: "")
        }

        let track = tracks[index]

        return TrackInfo(
            id: track.id,
            name: .init(stringLiteral: track.name),
            artist: track.artists.first?.name ?? "😅😅",
            imageUrl: track.album?.images.first?.url ?? ""
        )
    }

    var playButtonInfo: ButtonState {
        if isPlaying {
            return ButtonState(systemName: "pause.fill", isEnabled: true)
        } else if canReplay {
            return ButtonState(systemName: "memories", isEnabled: true)
        } else if canPlay {
            return ButtonState(systemName: "play.fill", isEnabled: true)
        }

        return ButtonState(systemName: "play.fill", isEnabled: false)
    }

    var likeButtonInfo: ButtonState {
        if isSaved {
            return ButtonState(systemName: "heart.fill", isEnabled: true)
        } else {
            return ButtonState(systemName: "heart", isEnabled: true)
        }
    }

    var canPlay: Bool {
        !tracks.isEmpty && player != nil && (player?.rate == 0.0 || currentTime >= trackDuration || currentTime == 0)
    }

    var isPlaying: Bool {
        player?.rate != 0.0 && player != nil && player?.currentItem != nil
    }

    var canReplay: Bool {
        canPlay && !hasNext && player?.currentItem == nil
    }

    var canScroll: Bool {
        (isPlaying || canPlay) && !canReplay
    }

    var hasTracks: Bool {
        !tracks.isEmpty
    }

    var hasNext: Bool {
        guard player != nil else {
            return false
        }

        if tracks.count <= 1 {
            return false
        }

        if index < tracks.count - 1 {
            return true
        }

        return false
    }

    var canRewind: Bool {
        currentTime > trackDuration * 0.1 || index > 0
    }

    var trackDuration: Float {
        guard let duration = player?.currentItem?.duration.seconds, duration >= .zero, !duration.isNaN else {
            return 30
        }

        return Float((player?.currentItem?.duration.seconds)!)
    }

    var currentTime: Float {
        Float(player?.currentItem?.currentTime().seconds ?? .zero)
    }

    func play(track: Track) {
        tracks = [track]

        guard let urlString = track.preview_url, let url = URL(string: urlString) else {
            return
        }

        player = AVQueuePlayer(items: [AVPlayerItem(url: url)])

        addPublishers { [weak self] _ in
            self?.index = 0
        }

        player?.play()
    }

    private func play(tracks: [Track]) {
        index = -1

        player = AVQueuePlayer(items: tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }

            return AVPlayerItem(url: url)
        })

        addPublishers { [weak self] item in
            if item != nil {
                self?.index += 1
            }
        }

        player?.play()
    }

    func play(tracks: [Track], from viewModel: PlaylistViewModel) {
        index = -1

        endpoint = viewModel.endpoint
        currentOffset = viewModel.currentOffset
        total = viewModel.total

        self.tracks = tracks.compactMap {
            guard $0.preview_url != nil else {
                return nil
            }

            return $0
        }

        player = AVQueuePlayer(items: self.tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }

            return AVPlayerItem(url: url)
        })

        addPublishers { [weak self] item in
            if item != nil {
                self?.index += 1
            }
            if !(self?.hasNext ?? true) {
                self?.fetchSongs()
            }
        }

        player?.play()
    }

    private func fetchSongs() {
        guard currentOffset < total else {
            return
        }

        let group = DispatchGroup()

        let request = Request(
            endpoint: endpoint,
            query: [
                APIKeys.limit: offset,
                APIKeys.offset: currentOffset,
            ]
        )

        group.enter()
        Task {
            try await Network.shared.execute(request, expecting: TracksResponse.self, success: { [weak self] response in
                let tracks: [Track] = response.items.compactMap {
                    guard $0.track.preview_url != nil else {
                        return nil
                    }

                    return $0.track
                }

                self?.currentOffset += response.items.count
                self?.tracks.append(contentsOf: tracks)

                for track in tracks {
                    guard let url = URL(string: track.preview_url!) else {
                        continue
                    }

                    self?.player?.insert(AVPlayerItem(url: url), after: self?.player?.items().last)
                }

                group.leave()
            })
        }

        group.wait()
    }

    private func checkSavedTracks() {
        guard index < tracks.count, index >= 0 else {
            return
        }

        let request = Request(
            endpoint: Endpoint.checkSavedTracks,
            query: [
                APIKeys.ids: tracks[index].id,
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: [Bool].self, success: { [weak self] response in
                DispatchQueue.main.async { [weak self] in
                    self?.isSaved = response.first ?? false
                }
            })
        }
    }

    func toggleSavedTrack() {
        guard index < tracks.count, index >= 0 else {
            return
        }

        let request = Request(
            endpoint: Endpoint.savedTracks,
            method: isSaved ? .delete : .put,
            body: [
                APIKeys.ids: [tracks[index].id],
            ]
        )

        Task {
            try await Network.shared.execute(request, expecting: EmptyResponse.self)
            DispatchQueue.main.async { [weak self] in
                self?.isSaved.toggle()
            }
        }
    }

    func togglePlayback() {
        if isPlaying {
            player?.pause()
        } else if currentItem == nil, !tracks.isEmpty {
            if tracks.count == 1, let track = tracks.first {
                play(track: track)
            } else {
                play(tracks: tracks)
            }
        } else {
            player?.play()
        }
    }

    func playNext() {
        if hasNext {
            player?.advanceToNextItem()
        }
    }

    func playPrevious() {
        guard currentTime <= trackDuration * 0.1, tracks.count > 1 else {
            seek(to: 0.0)
            return
        }

        guard index > 0 else {
            return
        }

        var playerItems: [AVPlayerItem] = []
        for i in (index - 1)..<tracks.count {
            guard let url = URL(string: tracks[i].preview_url!) else {
                return
            }

            playerItems.append(AVPlayerItem(url: url))
        }

        index -= 2

        player?.removeAllItems()
        for playerItem in playerItems {
            player?.insert(playerItem, after: player?.items().last)
        }

        addPublishers { [weak self] item in
            if item != nil {
                self?.index += 1
            }
            if !(self?.hasNext ?? true) {
                self?.fetchSongs()
            }
        }

        player?.play()
    }

    func seek(to position: Float) {
        player?.seek(to: CMTimeMake(value: Int64(position * 1000), timescale: 1000))
    }

    var scrollState: PlayerScrubState = .reset {
        didSet {
            switch scrollState {
            case .reset:
                return
            case .scrollStarted:
                return
            case let .scrollEnded(position):
                player?.seek(to: CMTime(seconds: TimeInterval(position), preferredTimescale: 1000))
            }
        }
    }

    enum PlayerScrubState: Equatable {
        case reset
        case scrollStarted
        case scrollEnded(Float)
    }

    deinit {
        cancelSubscriptions()
    }
}

// MARK: - Cancellables

extension PlayerViewModel {
    private func addPublishers(currentItemCompletion: @escaping (AVPlayerItem?) -> Void) {
        cancelSubscriptions()
        addPlayerPublisher(for: \.currentItem, completion: { [weak self] item in
            self?.currentItem = item
            currentItemCompletion(item)
            self?.checkSavedTracks()
            self?.updateNowPlayingInfo()
        })

        addPlayerPublisher(for: \.rate) { [weak self] rate in
            self?.rate = rate
        }

        addTimer()
    }

    func addTimer() {
        Timer.publish(every: 0.001, on: RunLoop.main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                switch self?.scrollState {
                case .reset:
                    self?.currentProgress = self?.currentTime ?? 0.0
                case .scrollStarted:
                    break
                case let .scrollEnded(position):
                    self?.scrollState = .reset
                    self?.currentProgress = position
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func addPlayerPublisher<T>(
        for keyPath: KeyPath<AVQueuePlayer, T>,
        completion: @escaping (T) -> Void
    ) {
        player?.publisher(for: keyPath)
            .receive(on: RunLoop.main)
            .sink { value in
                completion(value)
            }
            .store(in: &cancellables)
    }

    private func cancelSubscriptions() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

// MARK: - Now Playing info

extension PlayerViewModel {
    private func updateNowPlayingInfo() {
        guard index >= 0, index < tracks.count else {
            return
        }
        let track = tracks[index]

        nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = trackDuration
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = hasNext

        if let image = getCoverImage(from: track.imageUrl ?? "") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ in
                image
            })
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        } else {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = nil
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    private func getCoverImage(from url: String) -> UIImage? {
        var image: UIImage?
        let group = DispatchGroup()

        if let imageUrl = URL(string: url) {
            group.enter()

            Task {
                let imageData = try? Data(contentsOf: imageUrl)

                if let imageData = imageData {
                    image = UIImage(data: imageData)
                }
                group.leave()
            }
        }
        group.wait()

        return image
    }
}

// MARK: - Now Playing actions

extension PlayerViewModel {
    private func registerTargetForRemoteCommands() {
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(handler: togglePlayPause)
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(handler: playPreviousTrack)
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(handler: playNextTrack)
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(handler: didChangePlaybackPosition)
    }

    private func togglePlayPause(event _: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        togglePlayback()
        updateNowPlayingInfo()
        return .success
    }

    func playNextTrack(event _: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        playNext()
        return .success
    }

    func playPreviousTrack(event _: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        playPrevious()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        return .success
    }

    func didChangePlaybackPosition(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let event = event as? MPChangePlaybackPositionCommandEvent else {
            return .commandFailed
        }
        seek(to: Float(event.positionTime))
        return .success
    }
}
