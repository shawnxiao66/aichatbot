//
//  SignUpView.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService = AuthService.shared
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var age: String = ""
    @State private var gender: String = "male"
    @State private var preferredCharacterGender: String = "other"
    @State private var isSigningUp: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var registrationSuccess: Bool = false
    private let preferredGenderKey = "preferred_character_gender"
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo 或标题
                        VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.accentSecondary)
                            
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            
                        Text("Join us and start your AI journey")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textMuted)
                        }
                        .padding(.top, 40)
                        
                        // 输入框
                        VStack(spacing: 20) {
                            // 用户名
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Enter username", text: $username)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // 邮箱
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
                            
                            // 密码
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                SecureField("Enter password", text: $password)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(AppColors.textPrimary)
                                    .textContentType(.newPassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                            }
                            
                            // 确认密码
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                SecureField("Enter password again", text: $confirmPassword)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(AppColors.textPrimary)
                                    .textContentType(.newPassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                            }
                            
                            // 年龄
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Age")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Enter age", text: $age)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                                    .keyboardType(.numberPad)
                            }
                            
                            // 性别
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        gender = "male"
                                    }) {
                                        Text("Male")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                gender == "male" ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.accentPrimary.opacity(0.9),
                                                        AppColors.accentSecondary.opacity(0.9)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.cardBackground,
                                                        AppColors.cardBackground
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(16)
                                    }
                                    
                                    Button(action: {
                                        gender = "female"
                                    }) {
                                        Text("Female")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                gender == "female" ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.accentPrimary.opacity(0.9),
                                                        AppColors.accentSecondary.opacity(0.9)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.cardBackground,
                                                        AppColors.cardBackground
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            
                            // 角色偏好性别（可跳过）
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preferred character gender (optional)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        preferredCharacterGender = "male"
                                    }) {
                                        Text("Male")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                preferredCharacterGender == "male" ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.accentPrimary.opacity(0.9),
                                                        AppColors.accentSecondary.opacity(0.9)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.cardBackground,
                                                        AppColors.cardBackground
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(16)
                                    }
                                    
                                    Button(action: {
                                        preferredCharacterGender = "female"
                                    }) {
                                        Text("Female")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                preferredCharacterGender == "female" ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.accentPrimary.opacity(0.9),
                                                        AppColors.accentSecondary.opacity(0.9)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.cardBackground,
                                                        AppColors.cardBackground
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(16)
                                    }
                                    
                                    Button(action: {
                                        preferredCharacterGender = "other"
                                    }) {
                                        Text("Other")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                preferredCharacterGender == "other" ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.textMuted.opacity(0.6),
                                                        AppColors.textMuted.opacity(0.4)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        AppColors.cardBackground,
                                                        AppColors.cardBackground
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 注册按钮
                        Button(action: {
                            signUp()
                        }) {
                            HStack {
                                if isSigningUp {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textPrimary))
                                } else {
                                    Text("Sign Up")
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
                        .disabled(!isFormValid || isSigningUp)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        !age.isEmpty &&
        Int(age) != nil
    }
    
    private func signUp() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields and ensure passwords match"
            showError = true
            return
        }
        
        guard let ageInt = Int(age) else {
            errorMessage = "Please enter a valid age"
            showError = true
            return
        }
        
        isSigningUp = true
        authService.signUp(username: username, email: email, password: password, age: ageInt, gender: gender) { result in
            DispatchQueue.main.async {
                isSigningUp = false
                switch result {
                case .success:
                    // 注册成功后，关闭注册页面，MainTabView 会自动显示主界面
                    registrationSuccess = true
                    savePreferredCharacterGender()
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func savePreferredCharacterGender() {
        UserDefaults.standard.set(preferredCharacterGender, forKey: preferredGenderKey)
    }
}

#Preview {
    SignUpView()
        .preferredColorScheme(.dark)
}


