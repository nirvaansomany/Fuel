import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(FuelSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: FuelRadius.card, style: .continuous)
                    .fill(
                        FuelColor.cardBackground
                            .opacity(0.9)
                    )
                    .shadow(
                        color: FuelShadow.card.opacity(0.25),
                        radius: 20,
                        x: 0,
                        y: 12
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: FuelRadius.card, style: .continuous)
                    .stroke(FuelColor.cardBorder, lineWidth: 1)
            )
    }
}
