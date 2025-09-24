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
    @State private var showImagePicker = false
    @State private var pickedImage: UIImage?
    
    
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
                appUserId: authManager.currentUser?.appUserId ?? UserDefaults.standard.string(forKey: "app_user_id") ?? UUID().uuidString,
                username: editedUsername,
                email: authManager.currentUser?.email ?? "",
                role: authManager.currentUser?.role ?? .user,
                firstName: editedFirstName.isEmpty ? nil : editedFirstName,
                lastName: editedLastName.isEmpty ? nil : editedLastName,
                imageUrl: authManager.currentUser?.imageUrl,
                isActive: authManager.currentUser?.isActive ?? true,
                isPremium: authManager.currentUser?.isPremium ?? false,
                premiumExpiresAt: authManager.currentUser?.premiumExpiresAt,
                premiumWillRenew: authManager.currentUser?.premiumWillRenew,
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

    // MARK: - Upload profile image to Supabase Storage and update user
    private func uploadProfileImage(_ image: UIImage) async {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        guard let user = authManager.currentUser else { return }

        do {
            let fileName = "\(user.id)-\(Int(Date().timeIntervalSince1970)).jpg"
            let path = "\(fileName)"

            // Upload to storage bucket 'profile-images'
            _ = try await SupabaseConfig.shared.client.storage
                .from("profile-images")
                .upload(path, data: data, options: .init(contentType: "image/jpeg", upsert: true))

            // Build public URL
            let publicURL = try SupabaseConfig.shared.client.storage
                .from("profile-images")
                .getPublicURL(path: path)

            // Update user image_url
            let updatedUser = User(
                id: user.id,
                appUserId: user.appUserId,
                username: user.username,
                email: user.email,
                role: user.role,
                firstName: user.firstName,
                lastName: user.lastName,
                imageUrl: publicURL.absoluteString,
                isActive: user.isActive,
                isPremium: user.isPremium,
                premiumExpiresAt: user.premiumExpiresAt,
                premiumWillRenew: user.premiumWillRenew,
                createdAt: user.createdAt,
                updatedAt: Date()
            )

            try await SupabaseConfig.shared.client
                .from("users")
                .update(updatedUser)
                .eq("user_id", value: user.id)
                .execute()

            await authManager.loadUserProfile()
        } catch {
            print("Upload error: \(error)")
            await MainActor.run {
                self.showError = true
                self.errorMessage = "No se pudo subir la imagen. Intenta nuevamente."
            }
        }
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

                                    if let urlString = authManager.currentUser?.imageUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image.resizable().scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .clipShape(Circle())
                                            case .failure:
                                                Image(systemName: "person.circle.fill")
                                                    .font(.system(size: 120))
                                                    .foregroundColor(.blue)
                                            case .empty:
                                                ProgressView().tint(.blue)
                                            @unknown default:
                                                Image(systemName: "person.circle.fill")
                                                    .font(.system(size: 120))
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 120))
                                            .foregroundColor(.blue)
                                    }

                                    VStack {
                                        Spacer()
                                        HStack { Spacer()
                                            Button(action: { showImagePicker = true }) {
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                    .frame(width: 120, height: 120)
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
                                }

                                // Subscription
                                if let isPremium = authManager.currentUser?.isPremium {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Suscripción")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.medium)
                        HStack(spacing: 8) {
                            Text(isPremium ? "Pro" : "Free")
                                .font(.body.weight(.semibold))
                                .foregroundColor(isPremium ? .blue : .secondary)
                            if isPremium, let expires = authManager.currentUser?.premiumExpiresAt {
                                Text("· Renueva \(expires.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 24))
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $pickedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: pickedImage) { _, newValue in
                guard let img = newValue else { return }
                Task { await uploadProfileImage(img) }
            }
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

// MARK: - Image Picker Helper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.image = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.image = original
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
