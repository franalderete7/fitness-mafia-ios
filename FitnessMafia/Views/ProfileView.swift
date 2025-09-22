//
//  ProfileView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI
import Supabase


struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isEditing = false
    @State private var editedFirstName = ""
    @State private var editedLastName = ""
    @State private var editedUsername = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    
    private func startEditing() {
        if let user = authManager.currentUser {
            editedFirstName = user.firstName ?? ""
            editedLastName = user.lastName ?? ""
            editedUsername = user.username
        }
        isEditing = true
    }
    
    private func saveProfile() async {
        guard let userId = authManager.currentUser?.id else { return }
        
        isLoading = true
        showError = false
        
        do {
            let updatedUser = User(
                id: userId,
                username: editedUsername,
                email: authManager.currentUser?.email ?? "",
                role: authManager.currentUser?.role ?? .user,
                firstName: editedFirstName.isEmpty ? nil : editedFirstName,
                lastName: editedLastName.isEmpty ? nil : editedLastName,
                isActive: authManager.currentUser?.isActive ?? true,
                createdAt: authManager.currentUser?.createdAt ?? Date(),
                updatedAt: Date()
            )
            
            try await SupabaseConfig.shared.client
                .from("users")
                .update(updatedUser)
                .eq("user_id", value: userId)
                .execute()
            
            // Reload user profile
            await authManager.loadUserProfile()
            isEditing = false
            
        } catch {
            showError = true
            errorMessage = "Error al guardar los cambios: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func cancelEditing() {
        isEditing = false
        editedFirstName = ""
        editedLastName = ""
        editedUsername = ""
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 32) {
                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        }
                        
                        // Profile Card
                        VStack(spacing: 24) {
                            // Profile Avatar and Basic Info
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 120))
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(spacing: 12) {
                                    // Name Section
                                    if isEditing {
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Nombre")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .fontWeight(.medium)
                                                TextField("Nombre", text: $editedFirstName)
                                                    .textFieldStyle(.roundedBorder)
                                                    .font(.title3)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Apellido")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .fontWeight(.medium)
                                                TextField("Apellido", text: $editedLastName)
                                                    .textFieldStyle(.roundedBorder)
                                                    .font(.title3)
                                            }
                                        }
                                        .padding(.horizontal)
                                    } else {
                                        Text(authManager.currentUser?.displayName ?? "Usuario")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    // Username Section
                                    if isEditing {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Nombre de usuario")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .fontWeight(.medium)
                                            HStack {
                                                Text("@")
                                                    .foregroundColor(.secondary)
                                                TextField("usuario", text: $editedUsername)
                                                    .textFieldStyle(.roundedBorder)
                                                    .autocapitalization(.none)
                                                    .disableAutocorrection(true)
                                            }
                                        }
                                        .padding(.horizontal)
                                    } else {
                                        Text("@\(authManager.currentUser?.username ?? "usuario")")
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // User Details
                            VStack(spacing: 16) {
                                // Email
                                if let email = authManager.currentUser?.email {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Correo electrónico")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.medium)
                                        Text(email)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                }
                                
                                // User Role
                                if let role = authManager.currentUser?.role {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Rol")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.medium)
                                        Text(role.rawValue.capitalized == "User" ? "Usuario" : "Administrador")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                }
                                
                                // Account Status
                                if let isActive = authManager.currentUser?.isActive {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Estado de cuenta")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.medium)
                                        HStack {
                                            Circle()
                                                .fill(isActive ? Color.green : Color.red)
                                                .frame(width: 8, height: 8)
                                            Text(isActive ? "Activa" : "Inactiva")
                                                .font(.body)
                                                .foregroundColor(isActive ? .green : .red)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                }
                                
                                // Member Since
                                if let createdAt = authManager.currentUser?.createdAt {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Miembro desde")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.medium)
                                        Text(createdAt.formatted(.dateTime.month(.wide).year()))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        
                        // Sign Out Button
                        Button(action: {
                            Task {
                                do {
                                    try await authManager.signOut()
                                } catch {
                                    print("Sign out error: \(error)")
                                }
                            }
                        }) {
                            Text("Cerrar Sesión")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: HStack {
                    if isEditing {
                        Button("Cancelar") {
                            cancelEditing()
                        }
                        .foregroundColor(.red)
                        
                        Button(action: {
                            Task { await saveProfile() }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Guardar")
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(isLoading)
                    } else {
                        Button("Editar") {
                            startEditing()
                        }
                    }
                }
            )
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView()
        }
    }
}
