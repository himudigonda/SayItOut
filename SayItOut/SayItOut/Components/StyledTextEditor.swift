import SwiftUI

struct StyledTextEditor: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(NSColor.placeholderTextColor))
                    .padding(10)
            }
            
            TextEditor(text: $text)
                .font(.body)
                .padding()
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .shadow(radius: 2)
        }
        .padding(.horizontal)
    }
}
