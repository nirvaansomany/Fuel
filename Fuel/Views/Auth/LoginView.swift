import SwiftUI

struct LoginView: View {
    @ObservedObject var authService: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            FuelBackground()
            
            ScrollView {
                VStack(spacing: FuelSpacing.xl) {
                    // Logo/Title
                    VStack(spacing: FuelSpacing.sm) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [FuelColor.macroCalories, FuelColor.macroProtein],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Fuel")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(FuelColor.textPrimary)
                        
                        Text("Smart UCLA Dining")
                            .font(.subheadline)
                            .foregroundColor(FuelColor.textSecondary)
                    }
                    .padding(.top, FuelSpacing.xl)
                    
                    // Form
                    AppCard {
                        VStack(spacing: FuelSpacing.md) {
                            Text(isSignUp ? "Create Account" : "Welcome Back")
                                .font(.headline)
                                .foregroundColor(FuelColor.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if isSignUp {
                                textField(
                                    title: "Name",
                                    text: $name,
                                    icon: "person",
                                    keyboardType: .default
                                )
                            }
                            
                            textField(
                                title: "Email",
                                text: $email,
                                icon: "envelope",
                                keyboardType: .emailAddress
                            )
                            
                            passwordField()
                            
                            if let error = authService.error {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Submit Button
                            Button {
                                Task {
                                    await submit()
                                }
                            } label: {
                                HStack {
                                    if authService.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text(isSignUp ? "Sign Up" : "Log In")
                                            .bold()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: FuelRadius.card)
                                        .fill(FuelColor.accent)
                                )
                                .foregroundColor(.white)
                            }
                            .disabled(authService.isLoading || !isFormValid)
                            .opacity(isFormValid ? 1.0 : 0.6)
                            
                            // Toggle Sign Up / Login
                            Button {
                                withAnimation {
                                    isSignUp.toggle()
                                    authService.error = nil
                                }
                            } label: {
                                Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                                    .font(.subheadline)
                                    .foregroundColor(FuelColor.accent)
                            }
                        }
                    }
                    .padding(.horizontal, FuelSpacing.lg)
                }
                .padding(.vertical, FuelSpacing.xl)
            }
        }
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        let passwordValid = password.count >= 6
        
        if isSignUp {
            return emailValid && passwordValid && !name.isEmpty
        } else {
            return emailValid && passwordValid
        }
    }
    
    // MARK: - Submit
    
    private func submit() async {
        if isSignUp {
            _ = await authService.signup(
                email: email,
                name: name,
                password: password
            )
        } else {
            _ = await authService.login(
                email: email,
                password: password
            )
        }
    }
    
    // MARK: - Components
    
    private func textField(
        title: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: FuelSpacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundColor(FuelColor.textSecondary)
            
            HStack(spacing: FuelSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(FuelColor.textSecondary)
                
                TextField("", text: text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(FuelColor.textPrimary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: FuelRadius.card)
                    .fill(FuelColor.cardBackground.opacity(0.9))
            )
        }
    }
    
    private func passwordField() -> some View {
        VStack(alignment: .leading, spacing: FuelSpacing.xs) {
            Text("Password")
                .font(.caption)
                .foregroundColor(FuelColor.textSecondary)
            
            HStack(spacing: FuelSpacing.sm) {
                Image(systemName: "lock")
                    .foregroundColor(FuelColor.textSecondary)
                
                if showPassword {
                    TextField("", text: $password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .foregroundColor(FuelColor.textPrimary)
                } else {
                    SecureField("", text: $password)
                        .foregroundColor(FuelColor.textPrimary)
                }
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(FuelColor.textSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: FuelRadius.card)
                    .fill(FuelColor.cardBackground.opacity(0.9))
            )
        }
    }
}

