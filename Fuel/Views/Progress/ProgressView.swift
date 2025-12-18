import SwiftUI

struct ProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var monthlyLineProgress: CGFloat = 0
    @State private var yearlyLineProgress: CGFloat = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: FuelSpacing.lg) {
                    SegmentedControl(
                        segments: viewModel.segments,
                        selectedIndex: $viewModel.selectedSegmentIndex
                    )

                    Group {
                        switch viewModel.selectedSegmentIndex {
                        case 0:
                            dailyView
                        case 1:
                            weeklyView
                        case 2:
                            monthlyView
                        default:
                            yearlyView
                        }
                    }
                }
                .padding(.horizontal, FuelSpacing.lg)
                .padding(.vertical, FuelSpacing.lg)
            }
            .navigationTitle("Progress")
            .onChange(of: viewModel.selectedSegmentIndex) { _, newValue in
                if newValue == 2 {
                    monthlyLineProgress = 0
                    withAnimation(.easeOut(duration: 1.0)) {
                        monthlyLineProgress = 1
                    }
                } else if newValue == 3 {
                    yearlyLineProgress = 0
                    withAnimation(.easeOut(duration: 1.0)) {
                        yearlyLineProgress = 1
                    }
                }
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private func macroPill(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(FuelColor.textSecondary)
        }
    }

    private var dailyView: some View {
        let summary = viewModel.dailySummary
        let totalMacros = max(
            Double(summary.proteinGrams + summary.carbsGrams + summary.fatGrams),
            1.0
        )
        let proteinPortion = Double(summary.proteinGrams) / totalMacros
        let carbsPortion = Double(summary.carbsGrams) / totalMacros
        let fatPortion = Double(summary.fatGrams) / totalMacros

        return VStack(spacing: FuelSpacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.md) {
                    Text("Daily Snapshot")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ZStack {
                        Circle()
                            .stroke(FuelColor.cardBorder.opacity(0.4), lineWidth: 20)

                        Circle()
                            .trim(from: 0, to: proteinPortion)
                            .stroke(
                                FuelColor.macroProtein,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        Circle()
                            .trim(from: proteinPortion, to: proteinPortion + carbsPortion)
                            .stroke(
                                FuelColor.macroCarbs,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        Circle()
                            .trim(
                                from: proteinPortion + carbsPortion,
                                to: proteinPortion + carbsPortion + fatPortion
                            )
                            .stroke(
                                FuelColor.macroFat,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            Text("\(summary.caloriesToday)")
                                .font(.title2)
                                .bold()
                                .foregroundColor(FuelColor.textPrimary)
                            Text("kcal today")
                                .font(.caption)
                                .foregroundColor(FuelColor.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)

                    HStack {
                        macroPill(
                            title: "Protein",
                            value: "\(summary.proteinGrams) g",
                            color: FuelColor.macroProtein
                        )
                        Spacer()
                        macroPill(
                            title: "Carbs",
                            value: "\(summary.carbsGrams) g",
                            color: FuelColor.macroCarbs
                        )
                        Spacer()
                        macroPill(
                            title: "Fat",
                            value: "\(summary.fatGrams) g",
                            color: FuelColor.macroFat
                        )
                    }
                    .font(.subheadline)
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Key Vitamins Today")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: FuelSpacing.sm) {
                            ForEach(viewModel.keyVitaminsToday, id: \.self) { vitamin in
                                Chip(title: vitamin, isSelected: true)
                            }
                        }
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Daily Insights")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.dailyInsights, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Tips from Your Coach")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.dailyCoachTips, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }
        }
    }

    private var weeklyView: some View {
        VStack(spacing: FuelSpacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.md) {
                    Text("Weekly Trend")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)
                    Text("Weekly Goal: 5/7 days hit protein target")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    HStack(spacing: FuelSpacing.sm) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: FuelRadius.card)
                                    .fill(FuelColor.cardBackground.opacity(0.9))
                                    .frame(height: 80)
                                    .overlay(
                                        Circle()
                                            .fill(FuelColor.accent)
                                            .frame(width: 6, height: 6)
                                            .offset(y: -40)
                                    )
                                Text(day)
                                    .font(.caption2)
                                    .foregroundColor(FuelColor.textSecondary)
                            }
                        }
                    }
                    .frame(height: 120)
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Weekly Insights")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.weeklyInsights, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Tips from Your Coach")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.weeklyCoachTips, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }
        }
    }

    private var monthlyView: some View {
        VStack(spacing: FuelSpacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.md) {
                    Text("Monthly Trend")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)
                    Text("Average macro intake per week")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let baselineY = height * 0.8

                        ZStack {
                            // X-axis
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: baselineY))
                                path.addLine(to: CGPoint(x: width, y: baselineY))
                            }
                            .stroke(FuelColor.cardBorder.opacity(0.7), lineWidth: 1)

                            // Trend line with animation
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: baselineY * 0.9))
                                path.addCurve(
                                    to: CGPoint(x: width, y: baselineY * 0.8),
                                    control1: CGPoint(x: width * 0.3, y: baselineY * 0.7),
                                    control2: CGPoint(x: width * 0.6, y: baselineY * 1.05)
                                )
                            }
                            .trim(from: 0, to: monthlyLineProgress)
                            .stroke(FuelColor.macroCalories.opacity(0.9), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        }
                    }
                    .frame(height: 140)

                    HStack {
                        ForEach(["W1", "W2", "W3", "W4"], id: \.self) { label in
                            Text(label)
                                .font(.caption2)
                                .foregroundColor(FuelColor.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Monthly Insights")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.monthlyInsights, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Tips from Your Coach")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.monthlyCoachTips, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }
        }
    }

    private var yearlyView: some View {
        VStack(spacing: FuelSpacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.md) {
                    Text("Yearly Trend")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)
                    Text("Macro distribution over the year")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let baselineY = height * 0.8

                        ZStack {
                            // X-axis
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: baselineY))
                                path.addLine(to: CGPoint(x: width, y: baselineY))
                            }
                            .stroke(FuelColor.cardBorder.opacity(0.7), lineWidth: 1)

                            // Glowing shadow
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: baselineY * 0.9))
                                path.addCurve(
                                    to: CGPoint(x: width, y: baselineY * 0.85),
                                    control1: CGPoint(x: width * 0.25, y: baselineY * 0.75),
                                    control2: CGPoint(x: width * 0.75, y: baselineY * 0.95)
                                )
                            }
                            .trim(from: 0, to: yearlyLineProgress)
                            .stroke(FuelColor.macroProtein.opacity(0.4), lineWidth: 10)
                            .blur(radius: 14)

                            // Main trend line
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: baselineY * 0.9))
                                path.addCurve(
                                    to: CGPoint(x: width, y: baselineY * 0.85),
                                    control1: CGPoint(x: width * 0.25, y: baselineY * 0.75),
                                    control2: CGPoint(x: width * 0.75, y: baselineY * 0.95)
                                )
                            }
                            .trim(from: 0, to: yearlyLineProgress)
                            .stroke(FuelColor.macroProtein.opacity(0.95), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        }
                    }
                    .frame(height: 140)

                    HStack {
                        ForEach(["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"], id: \.self) { label in
                            Text(label)
                                .font(.caption2)
                                .foregroundColor(FuelColor.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Yearly Insights")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.yearlyInsights, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Tips from Your Coach")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)

                    ForEach(viewModel.yearlyCoachTips, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                }
            }
        }
    }
}
