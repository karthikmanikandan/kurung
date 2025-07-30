import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "video.slash.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)

                VStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                Button(action: action) {
                    Label(actionTitle, systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    EmptyStateView(
        title: "No YouTube Shorts Available",
        message: "Pull to refresh or check your connection",
        actionTitle: "Retry",
        action: {}
    )
}
