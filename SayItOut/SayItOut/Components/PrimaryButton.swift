import SwiftUI

struct PrimaryButton: View {
    let text: String
    let iconName: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool

    var body: some View {
        Button(action: action) {
            HStack {
                if !iconName.isEmpty {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                }
                Text(isLoading ? "Processing..." : text)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isDisabled || isLoading ? Color.gray : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(isDisabled || isLoading)
        .opacity((isDisabled || isLoading) ? 0.5 : 1.0)
    }
}
