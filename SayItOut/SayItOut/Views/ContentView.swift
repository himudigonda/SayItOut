import SwiftUI
import AVKit

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var audioURL: URL? = nil
    @ObservedObject var audioPlayer = AudioPlayerService()
    @State private var isGenerating: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            HeaderView()
            
            StyledTextEditor(text: $inputText, placeholder: "Enter your text here...")

            HStack(spacing: 12) {
                PrimaryButton(
                    text: "Generate",
                    iconName: "waveform",
                    action: { Task { await generateSpeech() } },
                    isLoading: isGenerating,
                    isDisabled: inputText.isEmpty || isGenerating || isLoading
                )

                PlaybackControlButtons(audioURL: audioURL, audioPlayer: audioPlayer)
            }
            
            if let url = audioURL {
                PlaybackSlider(
                    playbackPosition: $audioPlayer.playbackPosition,
                    audioDuration: audioPlayer.audioDuration,
                    seek: { audioPlayer.seek(to: audioPlayer.playbackPosition) }
                )
            }
        }
        .padding()
        .frame(minWidth: 400, maxWidth: 600, minHeight: 400, maxHeight: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 8)
    }

    func generateSpeech() async {
        isGenerating = true
        isLoading = true
        defer { isGenerating = false; isLoading = false }

        do {
            let url = try await NetworkService.shared.generateSpeech(text: inputText)
            DispatchQueue.main.async {
                audioURL = url
                audioPlayer.loadAudio(url: url)
            }
        } catch {
            print("[ERROR] Failed to generate speech: \(error)")
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack {
            Text("SayItOut")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            Text("AI Text-to-Speech")
                .font(.system(size: 18))
                .foregroundColor(.secondary)
        }
    }
}

struct PlaybackControlButtons: View {
    var audioURL: URL?
    @ObservedObject var audioPlayer: AudioPlayerService

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if audioPlayer.isPlaying {
                    audioPlayer.pause()
                } else if let url = audioURL {
                    audioPlayer.play()
                }
            }) {
                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding()
                    .background(audioURL == nil ? Color.gray : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(audioURL == nil)

            if audioPlayer.isPlaying {
                Button(action: { audioPlayer.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
