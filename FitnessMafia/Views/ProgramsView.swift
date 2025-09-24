//
//  ProgramsView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

// Extension to add computed properties to Program for display
extension Program {
    var difficultySpanish: String {
        switch difficultyLevel {
        case .beginner: return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced: return "Avanzado"
        }
    }

    var displayColor: Color {
        switch difficultyLevel {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }

    var formattedDuration: String {
        "\(durationWeeks) semanas"
    }

    var subtitleText: String {
        if programType != nil {
            return programTypeSpanish
        }
        return isTemplate ? "Programa de plantilla" : "Programa personalizado"
    }

    var programTypeSpanish: String {
        switch programType?.lowercased() {
        case "strength": return "Fuerza"
        case "weight_loss", "weight loss": return "Pérdida de Peso"
        case "muscle_gain", "muscle gain": return "Ganancia Muscular"
        case "endurance": return "Resistencia"
        case "other": return "Otro"
        default: return programType ?? "General"
        }
    }
}

struct ProgramCard: View {
    @EnvironmentObject var authManager: AuthManager
    let program: Program

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(program.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    if let description = program.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                if authManager.currentUser?.isPremium != true {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 16) {
                Label(program.formattedDuration, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Label(program.difficultySpanish, systemImage: "chart.bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(program.displayColor.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(program.displayColor.opacity(0.2), lineWidth: 1)
                if authManager.currentUser?.isPremium != true {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.08))
                }
            }
        )
    }
}

struct ProgramsView: View {
    @State private var programs: [Program] = []
    @State private var isLoading = true
    @State private var error: DatabaseError?
    @State private var searchText = ""
    @State private var selectedCategory = "Todos"
    @State private var showPaywall = false
    @EnvironmentObject var authManager: AuthManager

    private let programService = ProgramService()

    var filteredPrograms: [Program] {
        let filtered = programs.filter { program in
            let matchesSearch = searchText.isEmpty ||
                program.name.localizedCaseInsensitiveContains(searchText) ||
                (program.description?.localizedCaseInsensitiveContains(searchText) ?? false)

            // For "Todos", show all programs
            if selectedCategory == "Todos" {
                return matchesSearch
            }

            // For specific categories, match the Spanish program type
            let matchesCategory = program.programTypeSpanish == selectedCategory
            return matchesSearch && matchesCategory
        }

        print("DEBUG: Filtering programs - selectedCategory: '\(selectedCategory)', searchText: '\(searchText)', programs: \(programs.count), filtered: \(filtered.count)")
        return filtered
    }

    var categoryTypes: [String] {
        // Extract unique program types from programs and translate them
        let uniqueTypes = Set(programs.compactMap { $0.programType })
        let spanishTypes = uniqueTypes.map { type in
            switch type.lowercased() {
            case "strength": return "Fuerza"
            case "weight_loss", "weight loss": return "Pérdida de Peso"
            case "muscle_gain", "muscle gain": return "Ganancia Muscular"
            case "endurance": return "Resistencia"
            case "other": return "Otro"
            default: return type.capitalized
            }
        }

        // Remove duplicates and sort, then add "Todos" at the beginning
        let sortedTypes = Array(Set(spanishTypes)).sorted()
        return ["Todos"] + sortedTypes
    }

    private func loadData() async {
        isLoading = true
        error = nil

        do {
            let programs = try await programService.fetchAll()
            await MainActor.run {
                self.programs = programs
                self.isLoading = false
                print("DEBUG: Loaded \(programs.count) programs")
            }
        } catch let error as DatabaseError {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknownError(error)
                self.isLoading = false
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Buscar programas", text: $searchText)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Category Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categoryTypes, id: \.self) { category in
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground))
                                    .foregroundColor(selectedCategory == category ? .blue : .primary)
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Cargando programas...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error al cargar programas")
                                .font(.headline)
                            Text(error.localizedDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Intentar de Nuevo") {
                                Task { await loadData() }
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .padding()
                    } else if filteredPrograms.isEmpty {
                        VStack(spacing: 16) {
                            if programs.isEmpty {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No se encontraron programas")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No se encontraron programas que coincidan")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Prueba con otros términos de búsqueda")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        // Programs List
                        VStack(spacing: 16) {
                            ForEach(filteredPrograms) { program in
                                Group {
                                    if authManager.currentUser?.isPremium == true {
                                        NavigationLink(destination: ProgramDetailView(program: program)) {
                                            ProgramCard(program: program)
                                                .environmentObject(authManager)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        Button {
                                            showPaywall = true
                                        } label: {
                                            ProgramCard(program: program)
                                                .environmentObject(authManager)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Programas")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .fullScreenCover(isPresented: $showPaywall, onDismiss: {
                // Refresh user to reflect new premium status if purchased
                Task { await authManager.loadUserProfile() }
            }) {
                PaywallView()
            }
            .task {
                await loadData()
            }
        }
    }
}

struct ProgramsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramsView()
    }
}
