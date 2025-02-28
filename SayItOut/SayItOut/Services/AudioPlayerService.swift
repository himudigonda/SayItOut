import AVKit
import Foundation

class AudioPlayerService: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var playbackPosition: Double = 0.0
    @Published var audioDuration: Double = 0.0
    @Published var currentURL: URL?
    private var player: AVPlayer?
    private var timeObserverToken: Any?

    init() {
        setupNotifications()
    }

    deinit {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }


    func loadAudio(url: URL) {
        currentURL = url
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: {
            DispatchQueue.main.async {
                let duration = playerItem.asset.duration
                self.audioDuration = CMTimeGetSeconds(duration)
            }
        })
        addTimeObserver()
    }

    func play() {
        guard let player = player else { return }
        player.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.seek(to: .zero)
        player?.pause()
        isPlaying = false
        playbackPosition = 0.0
    }

    func seek(to time: TimeInterval) {
        guard let player = player else { return }
        let seekTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: seekTime)
    }


    func addTimeObserver() {
        guard let player = player else { return }
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600) // Update interval

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            self.playbackPosition = CMTimeGetSeconds(time)
        }
    }

    func removeTimeObserver() {
        guard let player = player, let timeObserverToken = timeObserverToken else { return }
        player.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    @objc func playerDidFinishPlaying() {
        print("Audio Finished")
        stop()
    }

}
