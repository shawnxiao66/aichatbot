//
//  LoginView.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSignUp: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo or title
                        VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.accentSecondary)
                            
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            
                        Text("Login to continue")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textMuted)
                        }
                        .padding(.top, 60)
                        
                        // Input fields
                        VStack(spacing: 20) {
                            // Email input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Enter email", text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // Password input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                SecureField("Enter password", text: $password)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Login button
                        Button(action: {
                            login()
                        }) {
                            HStack {
                                if isLoggingIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textPrimary))
                                } else {
                                    Text("Login")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.accentPrimary.opacity(0.9),
                                        AppColors.accentSecondary.opacity(0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                        .padding(.horizontal, 20)
                        
                        // Sign up link
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textMuted)
                            
                            Button(action: {
                                showSignUp = true
                            }) {
                                Text("Sign up now")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.accentPrimary)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Only show close button when entering from other pages
                if authService.isLoggedIn {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EmptyView()
                    }
                }
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoggingIn = true
        authService.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoggingIn = false
                switch result {
                case .success:
                    // After successful login, MainTabView will automatically switch to main interface
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}


