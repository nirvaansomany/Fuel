import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: FuelSpacing.lg) {

                    AppCard {
                        HStack {
                            Text("Daily Tracker")
                                .font(.headline)
                                .foregroundColor(FuelColor.textPrimary)
                            Spacer()
                            Text("View details")
                                .font(.subheadline)
                                .foregroundColor(FuelColor.textSecondary)
                        }
                        .padding(.bottom, FuelSpacing.md)

                        Button {
                            selectedTab = 1
                        } label: {
                            let summary = viewModel.dailySummary
                            let progress = min(
                                Double(summary.caloriesToday) / Double(summary.caloriesTarget),
                                1.0
                            )

                            ZStack {
                                Circle()
                                    .stroke(
                                        FuelColor.cardBorder.opacity(0.5),
                                        lineWidth: 16
                                    )
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        AngularGradient(
                                            colors: [
                                                FuelColor.macroCalories,
                                                FuelColor.macroProtein,
                                                FuelColor.macroCarbs,
                                                FuelColor.macroFat,
                                                FuelColor.macroCalories
                                            ],
                                            center: .center
                                        ),
                                        style: StrokeStyle(
                                            lineWidth: 16,
                                            lineCap: .round
                                        )
                                    )
                                    .rotationEffect(.degrees(-90))

                                VStack(spacing: 4) {
                                    Text("\(summary.caloriesToday)")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(FuelColor.textPrimary)
                                    Text("calories today")
                                        .font(.caption)
                                        .foregroundColor(FuelColor.textSecondary)
                                }
                            }
                            .frame(width: 180, height: 180)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recommended Meal")
                                    .font(.headline)
                                    .foregroundColor(FuelColor.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(FuelColor.textSecondary)
                            }

                            if let currentMeal = viewModel.selectedMeal {
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.caption)
                                        .foregroundColor(FuelColor.textSecondary)
                                    Text(currentMeal.diningHall)
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(FuelColor.textPrimary)
                                    Spacer()
                                    Image(systemName: "heart")
                                        .foregroundColor(FuelColor.textSecondary)
                                }
                            }

                            TabView(selection: $viewModel.selectedMealIndex) {
                                ForEach(Array(viewModel.meals.enumerated()), id: \.offset) { index, meal in
                                    VStack(alignment: .leading, spacing: 12) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(meal.items) { item in
                                                HStack(spacing: FuelSpacing.sm) {
                                                    Text(item.emoji)
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(item.name)
                                                            .foregroundColor(FuelColor.textPrimary)
                                                        Text(item.servingDescription)
                                                            .font(.caption)
                                                            .foregroundColor(FuelColor.textSecondary)
                                                    }
                                                    Spacer()
                                                }
                                                .font(.subheadline)
                                            }
                                        }

                                        Spacer(minLength: FuelSpacing.lg)

                                        HStack {
                                            macroStat(title: "cal", value: "\(meal.totalCalories)")
                                            Spacer()
                                            macroStat(title: "protein", value: "\(meal.proteinGrams)g")
                                            Spacer()
                                            macroStat(title: "carbs", value: "\(meal.carbsGrams)g")
                                            Spacer()
                                            macroStat(title: "fat", value: "\(meal.fatGrams)g")
                                        }
                                        .font(.subheadline)
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(height: 290)
                        }
                    }

                    // Pager dots under the card
                    if !viewModel.meals.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(0..<viewModel.meals.count, id: \.self) { index in
                                Circle()
                                    .fill(index == viewModel.selectedMealIndex ? FuelColor.accent : FuelColor.cardBorder)
                                    .frame(width: index == viewModel.selectedMealIndex ? 10 : 6,
                                           height: index == viewModel.selectedMealIndex ? 10 : 6)
                                    .opacity(index == viewModel.selectedMealIndex ? 1.0 : 0.6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, FuelSpacing.lg)
                .padding(.vertical, FuelSpacing.lg)
            }
            .navigationTitle("Good Evening")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Let's plan your next meal")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)
                }
            }
        }
    }

    private func macroStat(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .bold()
                .foregroundColor(FuelColor.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(FuelColor.textSecondary)
        }
    }
}
