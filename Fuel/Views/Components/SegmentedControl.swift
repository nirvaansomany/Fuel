import SwiftUI

struct SegmentedControl: View {
    let segments: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                } label: {
                    Text(segments[index])
                        .font(.footnote)
                        .fontWeight(selectedIndex == index ? .semibold : .regular)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FuelSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: FuelRadius.pill, style: .continuous)
                                .fill(
                                    selectedIndex == index
                                        ? FuelColor.cardBackground.opacity(0.9)
                                        : Color.clear
                                )
                        )
                        .foregroundColor(
                            selectedIndex == index
                                ? FuelColor.textPrimary
                                : FuelColor.textSecondary
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: FuelRadius.pill, style: .continuous)
                .fill(FuelColor.cardBackground.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: FuelRadius.pill, style: .continuous)
                .stroke(FuelColor.cardBorder, lineWidth: 1)
        )
    }
}


