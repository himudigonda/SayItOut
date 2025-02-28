import SwiftUI

struct PlaybackSlider: View {
    @Binding var playbackPosition: Double
    let audioDuration: Double
    let seek: () -> Void

    var body: some View {
        HStack {
            Text(formatTimeInterval(playbackPosition))
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Slider(value: $playbackPosition, in: 0...audioDuration, onEditingChanged: { editing in
                if !editing {
                    seek()
                }
            })
            .accentColor(.blue)

            Text(formatTimeInterval(audioDuration))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval) ?? "0:00"
    }
}
