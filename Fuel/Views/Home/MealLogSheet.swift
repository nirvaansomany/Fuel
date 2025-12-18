import SwiftUI

/// Sheet for logging individual items from a meal or viewing/removing logged meals
struct MealLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var mealLog: MealLogService
    
    let meal: RecommendedMeal?
    let onLogItem: ((String, Int, Int, Int, Int) -> Void)?
    
    @State private var selectedItems: Set<String> = []
    
    init(meal: RecommendedMeal? = nil, mealLog: MealLogService, onLogItem: ((String, Int, Int, Int, Int) -> Void)? = nil) {
        self.meal = meal
        self.mealLog = mealLog
        self.onLogItem = onLogItem
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                FuelBackground()
                
                ScrollView {
                    VStack(spacing: FuelSpacing.lg) {
                        // Log individual items section
                        if let meal = meal {
                            logItemsSection(meal: meal)
                        }
                        
                        // Today's logged meals section
                        todaysLogsSection
                    }
                    .padding(.horizontal, FuelSpacing.lg)
                    .padding(.vertical, FuelSpacing.lg)
                }
            }
            .navigationTitle("Meal Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(FuelColor.accent)
                }
            }
        }
    }
    
    // MARK: - Log Individual Items
    
    private func logItemsSection(meal: RecommendedMeal) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.md) {
                Text("Log Items from \(meal.diningHall)")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)
                
                Text("Select items you ate:")
                    .font(.subheadline)
                    .foregroundColor(FuelColor.textSecondary)
                
                ForEach(meal.items) { item in
                    Button {
                        if selectedItems.contains(item.name) {
                            selectedItems.remove(item.name)
                        } else {
                            selectedItems.insert(item.name)
                        }
                    } label: {
                        HStack {
                            Image(systemName: selectedItems.contains(item.name) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedItems.contains(item.name) ? FuelColor.accent : FuelColor.textSecondary)
                            
                            Text(item.emoji)
                            
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .foregroundColor(FuelColor.textPrimary)
                                Text(item.servingDescription)
                                    .font(.caption)
                                    .foregroundColor(FuelColor.textSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 4)
                }
                
                if !selectedItems.isEmpty {
                    Button {
                        logSelectedItems(from: meal)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log \(selectedItems.count) Item\(selectedItems.count == 1 ? "" : "s")")
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
                }
            }
        }
    }
    
    private func logSelectedItems(from meal: RecommendedMeal) {
        // Calculate macros for selected items (estimate based on meal total / item count)
        let itemCount = meal.items.count
        guard itemCount > 0 else { return }
        
        let selectedCount = selectedItems.count
        let caloriesPerItem = meal.totalCalories / itemCount
        let proteinPerItem = meal.proteinGrams / itemCount
        let carbsPerItem = meal.carbsGrams / itemCount
        let fatPerItem = meal.fatGrams / itemCount
        
        // Log as a single entry with selected items
        let itemNames = meal.items.filter { selectedItems.contains($0.name) }.map { $0.name }
        mealLog.logCustomMeal(
            name: itemNames.joined(separator: ", "),
            calories: caloriesPerItem * selectedCount,
            protein: proteinPerItem * selectedCount,
            carbs: carbsPerItem * selectedCount,
            fat: fatPerItem * selectedCount
        )
        
        selectedItems.removeAll()
        dismiss()
    }
    
    // MARK: - Today's Logs
    
    private var todaysLogsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.md) {
                HStack {
                    Text("Today's Log")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)
                    
                    Spacer()
                    
                    let totals = mealLog.todaysTotals
                    Text("\(totals.calories) cal")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)
                }
                
                if mealLog.todaysLogs.isEmpty {
                    Text("No meals logged yet today")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, FuelSpacing.lg)
                } else {
                    ForEach(mealLog.todaysLogs) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.mealName)
                                    .foregroundColor(FuelColor.textPrimary)
                                Text("\(entry.calories) cal • \(entry.protein)g protein")
                                    .font(.caption)
                                    .foregroundColor(FuelColor.textSecondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                mealLog.removeEntry(entry)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                        
                        if entry.id != mealLog.todaysLogs.last?.id {
                            Divider()
                                .overlay(FuelColor.cardBorder)
                        }
                    }
                    
                    if !mealLog.todaysLogs.isEmpty {
                        Button {
                            mealLog.clearTodaysLogs()
                        } label: {
                            Text("Clear All")
                                .font(.subheadline)
                                .foregroundColor(.red.opacity(0.8))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, FuelSpacing.sm)
                    }
                }
            }
        }
    }
}

