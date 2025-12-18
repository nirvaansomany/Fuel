import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showActivityPicker = false
    @State private var showGoalTypePicker = false
    @AppStorage("appearancePreferenceIndex") private var appearanceIndex: Int = MockProfileData.selectedAppearanceIndex
    @State private var showExportAlert = false
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: FuelSpacing.lg) {
                    personalInfoSection
                    macroTargetsSection
                    vitaminsSection
                    dietaryRestrictionsSection
                    dislikedFoodsSection
                    diningHallPreferencesSection
                    notificationPreferencesSection
                    appSettingsSection
                    logOutSection
                }
                .padding(.horizontal, FuelSpacing.lg)
                .padding(.vertical, FuelSpacing.lg)
            }
            .navigationTitle("Profile & Settings")
            .confirmationDialog(
                "Activity Level",
                isPresented: $showActivityPicker,
                titleVisibility: .visible
            ) {
                ForEach(viewModel.activityLevels.indices, id: \.self) { index in
                    Button(viewModel.activityLevels[index]) {
                        viewModel.selectedActivityIndex = index
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog(
                "Goal Type",
                isPresented: $showGoalTypePicker,
                titleVisibility: .visible
            ) {
                ForEach(viewModel.goalTypes.indices, id: \.self) { index in
                    Button(viewModel.goalTypes[index]) {
                        viewModel.selectedGoalIndex = index
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                viewModel.selectedAppearanceIndex = appearanceIndex
            }
            .onChange(of: viewModel.selectedAppearanceIndex) { _, newValue in
                appearanceIndex = newValue
            }
            .alert("Export My Data", isPresented: $showExportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Data export will be implemented once the backend is connected. For now this is a design placeholder.")
            }
            .alert("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .task {
                await viewModel.refreshFromAPI()
            }
        }
    }

    // MARK: - Sections

    private var personalInfoSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.md) {
                Text("Personal Info")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                HStack(spacing: FuelSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(FuelColor.cardBackground.opacity(0.9))
                            .frame(width: 64, height: 64)
                        Text(viewModel.profile.initials)
                            .font(.title2)
                            .bold()
                            .foregroundColor(FuelColor.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.profile.name)
                            .font(.headline)
                            .foregroundColor(FuelColor.textPrimary)
                        Text(viewModel.profile.email)
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Gender")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)
                    
                    HStack(spacing: FuelSpacing.sm) {
                        Button {
                            viewModel.isMale = true
                        } label: {
                            Chip(
                                title: "Male",
                                isSelected: viewModel.isMale
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            viewModel.isMale = false
                        } label: {
                            Chip(
                                title: "Female",
                                isSelected: !viewModel.isMale
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: FuelSpacing.sm) {
                    HStack(spacing: FuelSpacing.sm) {
                        editableField(title: "Age", text: $viewModel.ageText, suffix: "years", keyboardType: .numberPad)
                        editableField(title: "Height", text: $viewModel.heightText, suffix: nil, placeholder: "5'10\"", keyboardType: .default)
                    }
                    HStack(spacing: FuelSpacing.sm) {
                        editableField(title: "Weight", text: $viewModel.weightText, suffix: "lbs", keyboardType: .numberPad)
                        editableField(title: "Goal Weight", text: $viewModel.goalWeightText, suffix: "lbs", keyboardType: .numberPad)
                    }
                }

                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Activity Level")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    Button {
                        showActivityPicker = true
                    } label: {
                        HStack {
                            Text(viewModel.activityLevels[viewModel.selectedActivityIndex])
                                .foregroundColor(FuelColor.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(FuelColor.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: FuelRadius.card, style: .continuous)
                                .fill(FuelColor.cardBackground.opacity(0.9))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var macroTargetsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.md) {
                Text("Macro Targets")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Goal Type")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    Button {
                        showGoalTypePicker = true
                    } label: {
                        HStack {
                            Text(viewModel.goalTypes[viewModel.selectedGoalIndex])
                                .foregroundColor(FuelColor.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(FuelColor.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: FuelRadius.card, style: .continuous)
                                .fill(FuelColor.cardBackground.opacity(0.9))
                        )
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: FuelSpacing.sm) {
                    HStack(spacing: FuelSpacing.sm) {
                        infoField(title: "Calories", value: "\(viewModel.profile.caloriesTarget) kcal")
                        infoField(title: "Protein", value: "\(viewModel.profile.proteinTarget) g")
                    }
                    HStack(spacing: FuelSpacing.sm) {
                        infoField(title: "Carbs", value: "\(viewModel.profile.carbsTarget) g")
                        infoField(title: "Fat", value: "\(viewModel.profile.fatTarget) g")
                    }
                }
            }
        }
    }

    private var vitaminsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                Text("Key Vitamins to Track")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                Text("Vitamins shown in Daily Snapshot")
                    .font(.subheadline)
                    .foregroundColor(FuelColor.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: FuelSpacing.sm) {
                        ForEach(viewModel.vitaminsToTrack, id: \.self) { vitamin in
                            Button {
                                if viewModel.selectedVitamins.contains(vitamin) {
                                    viewModel.selectedVitamins.remove(vitamin)
                                } else {
                                    viewModel.selectedVitamins.insert(vitamin)
                                }
                            } label: {
                                Chip(
                                    title: vitamin,
                                    isSelected: viewModel.selectedVitamins.contains(vitamin)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var dietaryRestrictionsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                Text("Dietary Restrictions")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: FuelSpacing.sm) {
                        ForEach(viewModel.dietaryRestrictions, id: \.self) { item in
                            Button {
                                if viewModel.selectedDietaryRestrictions.contains(item) {
                                    viewModel.selectedDietaryRestrictions.remove(item)
                                } else {
                                    viewModel.selectedDietaryRestrictions.insert(item)
                                }
                            } label: {
                                Chip(
                                    title: item,
                                    isSelected: viewModel.selectedDietaryRestrictions.contains(item)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var dislikedFoodsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                Text("Foods You Dislike")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: FuelSpacing.sm) {
                        ForEach(viewModel.dislikedFoods, id: \.self) { item in
                            Button {
                                if viewModel.selectedDislikedFoods.contains(item) {
                                    viewModel.selectedDislikedFoods.remove(item)
                                } else {
                                    viewModel.selectedDislikedFoods.insert(item)
                                }
                            } label: {
                                Chip(
                                    title: item,
                                    isSelected: viewModel.selectedDislikedFoods.contains(item)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var diningHallPreferencesSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                Text("Dining Hall Preferences")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: FuelSpacing.sm) {
                        ForEach(viewModel.diningHalls, id: \.self) { hall in
                            Button {
                                if viewModel.selectedDiningHalls.contains(hall) {
                                    viewModel.selectedDiningHalls.remove(hall)
                                } else {
                                    viewModel.selectedDiningHalls.insert(hall)
                                }
                            } label: {
                                Chip(
                                    title: hall,
                                    isSelected: viewModel.selectedDiningHalls.contains(hall)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var notificationPreferencesSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                Text("Notification Preferences")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                VStack(spacing: 0) {
                    ForEach(viewModel.notificationPreferences) { pref in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pref.title)
                                    .foregroundColor(FuelColor.textPrimary)
                                Text(pref.time)
                                    .font(.caption)
                                    .foregroundColor(FuelColor.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(FuelColor.textSecondary)
                        }
                        .padding(.vertical, FuelSpacing.sm)

                        if pref.id != viewModel.notificationPreferences.last?.id {
                            Divider()
                                .overlay(FuelColor.cardBorder)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Delivery Method (Multi-select)")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    SegmentedControl(
                        segments: viewModel.deliveryMethods,
                        selectedIndex: $viewModel.selectedDeliveryIndex
                    )
                }
            }
        }
    }

    private var appSettingsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                Text("App Settings")
                    .font(.headline)
                    .foregroundColor(FuelColor.textPrimary)

                VStack(alignment: .leading, spacing: FuelSpacing.sm) {
                    Text("Appearance")
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)

                    SegmentedControl(
                        segments: viewModel.appearanceOptions,
                        selectedIndex: $viewModel.selectedAppearanceIndex
                    )
                }

                VStack(spacing: 0) {
                    settingsRow(title: "Notification Permissions") {
                        openAppSettings()
                    }
                    Divider().overlay(FuelColor.cardBorder)
                    settingsRow(title: "Privacy Settings") {
                        openAppSettings()
                    }
                    Divider().overlay(FuelColor.cardBorder)
                    settingsRow(title: "Export My Data") {
                        showExportAlert = true
                    }
                }
            }
        }
    }

    private var logOutSection: some View {
        AppCard {
            VStack(alignment: .center, spacing: FuelSpacing.sm) {
                Button {
                    showLogoutConfirmation = true
                } label: {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(FuelColor.textPrimary)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Text("Delete Account")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private func infoField(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(FuelColor.textSecondary)
            Text(value)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundColor(FuelColor.textPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FuelRadius.card, style: .continuous)
                .fill(FuelColor.cardBackground.opacity(0.9))
        )
    }
    
    private func editableField(
        title: String,
        text: Binding<String>,
        suffix: String? = nil,
        placeholder: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(FuelColor.textSecondary)
            
            HStack(spacing: 4) {
                TextField(placeholder ?? "", text: text)
                    .keyboardType(keyboardType)
                    .font(.subheadline)
                    .foregroundColor(FuelColor.textPrimary)
                    .autocorrectionDisabled()
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.subheadline)
                        .foregroundColor(FuelColor.textSecondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FuelRadius.card, style: .continuous)
                .fill(FuelColor.cardBackground.opacity(0.9))
        )
    }

    private func settingsRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(FuelColor.textPrimary)
                Spacer()
                Image(systemName: "square.and.arrow.up.right")
                    .foregroundColor(FuelColor.textSecondary)
            }
            .padding(.vertical, FuelSpacing.sm)
        }
        .buttonStyle(.plain)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
