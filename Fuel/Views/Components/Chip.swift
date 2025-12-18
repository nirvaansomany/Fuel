import SwiftUI

struct Chip: View {
    let title: String
    var isSelected: Bool = false

    var body: some View {
        Text(title)
            .font(.caption)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, FuelSpacing.md)
            .padding(.vertical, FuelSpacing.xs)
            .background(
                Capsule()
                    .fill(FuelColor.cardBackground.opacity(isSelected ? 0.9 : 0.6))
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? FuelColor.accent : FuelColor.cardBorder,
                        lineWidth: 1
                    )
            )
            .foregroundColor(FuelColor.textPrimary)
    }
}


