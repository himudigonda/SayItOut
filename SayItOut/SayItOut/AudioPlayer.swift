//
//  AudioPlayer.swift
//  SayItOut
//
//  Created by Himansh Mudigonda on 2/28/25.
//

import AVFoundation

class AudioPlayer {
    static let shared = AudioPlayer()
    private var player: AVAudioPlayer?

    func play(url: URL) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    self.player = try? AVAudioPlayer(data: data)
                    self.player?.play()
                }
            } catch {
                print("Error playing audio: \(error)")
            }
        }
    }

    func stop() {
        player?.stop()
    }
}
