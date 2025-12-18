import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var mealLog = MealLogService.shared
    @State private var showMealLogSheet = false

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
                            let progress = summary.caloriesTarget > 0 
                                ? min(Double(summary.caloriesToday) / Double(summary.caloriesTarget), 1.0)
                                : 0

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
                                    Text("\(viewModel.dailySummary.caloriesToday)")
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

                                        Spacer(minLength: FuelSpacing.sm)

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
                            .frame(height: 260)
                            
                            // Log Meal Buttons
                            HStack(spacing: FuelSpacing.sm) {
                                // Log entire meal
                                Button {
                                    viewModel.logSelectedMeal()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Log All")
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: FuelRadius.card)
                                            .fill(FuelColor.accent)
                                    )
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(.plain)
                                
                                // Select specific items
                                Button {
                                    showMealLogSheet = true
                                } label: {
                                    HStack {
                                        Image(systemName: "checklist")
                                        Text("Select Items")
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: FuelRadius.card)
                                            .stroke(FuelColor.accent, lineWidth: 2)
                                    )
                                    .foregroundColor(FuelColor.accent)
                                }
                                .buttonStyle(.plain)
                            }
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
            .navigationTitle(greeting)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Let's plan your next meal")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showMealLogSheet = true
                    } label: {
                        Image(systemName: "list.bullet.clipboard")
                            .foregroundColor(FuelColor.accent)
                    }
                }
            }
            .alert("Meal Logged!", isPresented: $viewModel.showMealLoggedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                if let meal = viewModel.selectedMeal {
                    Text("Added \(meal.totalCalories) calories from \(meal.diningHall) to your daily total.")
                }
            }
            .sheet(isPresented: $showMealLogSheet) {
                MealLogSheet(meal: viewModel.selectedMeal, mealLog: mealLog)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onChange(of: mealLog.todaysLogs.count) { _, _ in
                // Refresh summary when logs change
                Task {
                    await viewModel.refresh()
                }
            }
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
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
