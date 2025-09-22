//
//  LoginView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager()

    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showSignupSuccessAlert = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 32) {
                    // App Logo/Title
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 120, height: 120)

                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        }

                        VStack(spacing: 8) {
                            Text("FitnessMafia")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Tu entrenador personal inteligente")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    .padding(.top, 60)

                    // Auth Form Card
                    VStack(spacing: 24) {
                        // Toggle between Sign Up and Sign In
                        Picker("Modo", selection: $isSignUp) {
                            Text("Iniciar Sesión").tag(false)
                            Text("Crear Cuenta").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .frame(height: 50)
                        .padding(.horizontal, 4)

                        // Form Fields
                        VStack(spacing: 16) {
                            // Email (always required)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Correo electrónico")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)

                                TextField("tu@email.com", text: $email)
                                    .textFieldStyle(.plain)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }

                            // Password (always required)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)

                                SecureField("Mínimo 6 caracteres", text: $password)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }

                            // Additional fields for Sign Up
                            if isSignUp {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nombre de usuario")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)

                                    TextField("usuario123", text: $username)
                                        .textFieldStyle(.plain)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                }

                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Nombre")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)

                                        TextField("Juan", text: $firstName)
                                            .textFieldStyle(.plain)
                                            .autocapitalization(.words)
                                            .padding()
                                            .background(Color(.secondarySystemBackground))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Apellido")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)

                                        TextField("Pérez", text: $lastName)
                                            .textFieldStyle(.plain)
                                            .autocapitalization(.words)
                                            .padding()
                                            .background(Color(.secondarySystemBackground))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }

                        // Error Message
                        if let errorMessage = authManager.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Action Button
                        Button(action: handleAuth) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.blue)
                                    .frame(height: 56)

                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isSignUp ? "Crear Cuenta" : "Iniciar Sesión")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(authManager.isLoading || !isFormValid)
                        .padding(.horizontal, 4)
                        .padding(.top, 8)

                        // Additional actions
                        if !isSignUp {
                            Button("¿Olvidaste tu contraseña?") {
                                // TODO: Implement password reset
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.top, 12)
                        }

                        // Terms for Sign Up
                        if isSignUp {
                            Text("Al crear una cuenta, aceptas nuestros términos de servicio y política de privacidad.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        }
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .alert("Cuenta creada exitosamente", isPresented: $showSignupSuccessAlert) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text("Se ha enviado un email de confirmación a \(email). Por favor verifica tu correo electrónico antes de iniciar sesión.")
        }
    }

    private var isFormValid: Bool {
        if authManager.isLoading { return false }

        let emailValid = !email.isEmpty && email.contains("@")
        let passwordValid = password.count >= 6

        if isSignUp {
            return emailValid && passwordValid && !username.isEmpty && !firstName.isEmpty && !lastName.isEmpty
        } else {
            return emailValid && passwordValid
        }
    }

    private func handleAuth() {
        Task {
            do {
                if isSignUp {
                    try await authManager.signUp(
                        email: email,
                        password: password,
                        username: username,
                        firstName: firstName,
                        lastName: lastName
                    )
                    // Show success alert for signup
                    showSignupSuccessAlert = true
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
            } catch {
                // Error is handled by AuthManager and displayed in UI
                print("Auth error: \(error)")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
