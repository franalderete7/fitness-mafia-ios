//
//  ExercisesView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

// Extension to add color and computed properties to Exercise
extension Exercise {
    var displayColor: Color {
        switch categoryId {
        case 1: return .blue      // Chest
        case 2: return .green     // Back
        case 3: return .orange    // Legs
        case 4: return .red       // Shoulders
        case 5: return .purple    // Arms
        case 6: return .pink      // Core
        case 7: return .yellow    // Cardio
        case 8: return .indigo    // Full Body
        default: return .gray
        }
    }

    var categoryName: String {
        switch categoryId {
        case 1: return "Chest"
        case 2: return "Back"
        case 3: return "Legs"
        case 4: return "Shoulders"
        case 5: return "Arms"
        case 6: return "Core"
        case 7: return "Cardio"
        case 8: return "Full Body"
        default: return "Other"
        }
    }

    var categoryNameSpanish: String {
        switch categoryId {
        case 1: return "Pecho"
        case 2: return "Espalda"
        case 3: return "Piernas"
        case 4: return "Hombros"
        case 5: return "Brazos"
        case 6: return "Core"
        case 7: return "Cardio"
        case 8: return "Cuerpo Completo"
        default: return "Otro"
        }
    }

    var formattedDuration: String? {
        guard let seconds = defaultDurationSeconds else { return nil }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        if minutes > 0 {
            return remainingSeconds > 0 ? "\(minutes)m \(remainingSeconds)s" : "\(minutes)m"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}

struct HorizontalExerciseCard: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 16) {
            // Exercise Image - Now shows actual image from database
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)

                if let imageUrl = exercise.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure(_):
                            // Fallback to icon if image fails to load
                            Image(systemName: "dumbbell.fill")
                                .font(.title2)
                                .foregroundColor(exercise.displayColor)
                        @unknown default:
                            Image(systemName: "dumbbell.fill")
                                .font(.title2)
                                .foregroundColor(exercise.displayColor)
                        }
                    }
                } else {
                    // No image URL provided, show icon
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(exercise.displayColor)
                }
            }

            // Exercise Info
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(exercise.categoryNameSpanish)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Label(exercise.difficultyLevel.rawValue.capitalized,
                          systemImage: "chart.bar")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let duration = exercise.formattedDuration {
                        Label(duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ExercisesView: View {
    @State private var selectedExercise: Exercise? = nil
    @State private var searchText = ""
    @State private var selectedCategory = "Todos"
    @State private var exercises: [Exercise] = []
    @State private var categories: [ExerciseCategory] = []
    @State private var isLoading = true
    @State private var error: DatabaseError?

    private let exerciseService = ExerciseService()

    var filteredExercises: [Exercise] {
        let filtered = exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText)

            // For "Todos", show all exercises
            if selectedCategory == "Todos" {
                return matchesSearch
            }

            // For specific categories, match the Spanish name
            let matchesCategory = exercise.categoryNameSpanish == selectedCategory
            return matchesSearch && matchesCategory
        }

        print("DEBUG: Filtering - selectedCategory: '\(selectedCategory)', searchText: '\(searchText)', exercises: \(exercises.count), filtered: \(filtered.count)")
        return filtered
    }

    var categoryNames: [String] {
        // If categories are not loaded yet, return basic Spanish categories
        if categories.isEmpty {
            return ["Todos", "Pecho", "Espalda", "Piernas", "Hombros", "Brazos", "Core", "Cardio", "Cuerpo Completo"]
        }

        let spanishNames = categories.map { category in
            switch category.id {
            case 1: return "Pecho"
            case 2: return "Espalda"
            case 3: return "Piernas"
            case 4: return "Hombros"
            case 5: return "Brazos"
            case 6: return "Core"
            case 7: return "Cardio"
            case 8: return "Cuerpo Completo"
            default: return category.name // Fallback to original name
            }
        }
        return ["Todos"] + spanishNames
    }

    private func loadData() async {
        isLoading = true
        error = nil

        do {
            // Load exercises and categories sequentially to avoid Sendable constraints
            let exercises = try await exerciseService.fetchAll()
            let categories = try await exerciseService.getExerciseCategories() ?? []

            print("DEBUG: Loaded \(exercises.count) exercises and \(categories.count) categories")

            await MainActor.run {
                self.exercises = exercises
                self.categories = categories
                self.isLoading = false
                print("DEBUG: UI updated - exercises count: \(self.exercises.count), categories count: \(self.categories.count)")
            }
        } catch let error as DatabaseError {
            print("DEBUG: DatabaseError - \(error.localizedDescription)")
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        } catch {
            print("DEBUG: Unknown error - \(error.localizedDescription)")
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
                        TextField("Buscar ejercicios...", text: $searchText)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categoryNames, id: \.self) { category in
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

                    // Loading State
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Cargando ejercicios...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    }
                    // Error State
                    else if let error = error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error al cargar ejercicios")
                                .font(.headline)
                            Text(error.localizedDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Intentar de Nuevo") {
                                Task {
                                    await loadData()
                                }
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .padding()
                    }
                    // Empty State
                    else if exercises.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "dumbbell")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No se encontraron ejercicios")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    }
                    // Exercises List
                    else {
                        VStack(spacing: 16) {

                            ForEach(filteredExercises) { exercise in
                                HorizontalExerciseCard(exercise: exercise)
                                    .onTapGesture {
                                        selectedExercise = exercise
                                    }
                                    .onAppear {
                                        print("DEBUG: Rendering exercise: \(exercise.name), category: \(exercise.categoryNameSpanish)")
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Ejercicios")
                .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
            .task {
                await loadData()
            }
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}
