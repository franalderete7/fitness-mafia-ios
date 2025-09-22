//
//  WorkoutDetailView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

// Extension to add computed properties to Block for display
extension Block {
    var blockTypeSpanish: String {
        switch blockType {
        case .warmup: return "Calentamiento"
        case .main: return "Principal"
        case .cooldown: return "Enfriamiento"
        case .superset: return "Superserie"
        case .circuit: return "Circuito"
        case .standard: return "Estándar"
        }
    }
}

// Extension to add computed properties to BlockExercise for display
extension BlockExercise {
    var formattedSets: String {
        if let sets = sets {
            return "\(sets) series"
        }
        return ""
    }

    var formattedRepetitions: String {
        if let repetitions = repetitions {
            return "\(repetitions) repeticiones"
        }
        return ""
    }

    var formattedWeight: String {
        if let weight = weightKg {
            return "\(weight) kg"
        }
        return ""
    }

    var formattedDuration: String {
        if let duration = durationSeconds {
            return "\(duration) segundos"
        }
        return ""
    }

    var formattedRest: String {
        if let rest = restSeconds {
            return "descanso \(rest) segundos"
        }
        return ""
    }
}

struct ExerciseInBlockRow: View {
    let exercise: Exercise
    let blockExercise: BlockExercise

    private var exerciseDetails: [String] {
        var details: [String] = []
        if !blockExercise.formattedSets.isEmpty { details.append(blockExercise.formattedSets) }
        if !blockExercise.formattedRepetitions.isEmpty { details.append(blockExercise.formattedRepetitions) }
        if !blockExercise.formattedWeight.isEmpty { details.append(blockExercise.formattedWeight) }
        if !blockExercise.formattedDuration.isEmpty { details.append(blockExercise.formattedDuration) }
        return details
    }

    var body: some View {
        HStack(spacing: 12) {
            // Exercise Image - same as in ExercisesView
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)

                if let imageUrl = exercise.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.7)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        case .failure(_):
                            // Fallback to icon if image fails to load
                            Image(systemName: "dumbbell.fill")
                                .font(.title3)
                                .foregroundColor(exercise.displayColor)
                        @unknown default:
                            Image(systemName: "dumbbell.fill")
                                .font(.title3)
                                .foregroundColor(exercise.displayColor)
                        }
                    }
                } else {
                    Image(systemName: "dumbbell.fill")
                        .font(.title3)
                        .foregroundColor(exercise.displayColor)
                }
            }

            // Exercise info
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                // Show sets/reps/weight/duration/rest
                if !exerciseDetails.isEmpty {
                    Text(exerciseDetails.joined(separator: " • "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !blockExercise.formattedRest.isEmpty {
                    Text(blockExercise.formattedRest)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let notes = blockExercise.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

struct BlockDisclosureGroup: View {
    let block: Block
    let exercisesWithInfo: [(exercise: Exercise, blockExercise: BlockExercise)]
    @Binding var selectedExercise: Exercise?

    var body: some View {
        DisclosureGroup {
            VStack(spacing: 0) {
                ForEach(exercisesWithInfo, id: \.blockExercise.id) { exerciseData in
                    ExerciseInBlockRow(exercise: exerciseData.exercise, blockExercise: exerciseData.blockExercise)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExercise = exerciseData.exercise
                        }

                    if exerciseData.blockExercise.id != exercisesWithInfo.last?.blockExercise.id {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(block.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    Text(block.blockTypeSpanish)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if block.restBetweenExercises > 0 {
                        Text("Descanso: \(block.restBetweenExercises)s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let description = block.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var blockData: [(block: Block, workoutBlock: WorkoutBlock)] = []
    @State private var blockExercisesData: [Int: [(exercise: Exercise, blockExercise: BlockExercise)]] = [:]
    @State private var isLoading = true
    @State private var error: DatabaseError?
    @State private var selectedExercise: Exercise? = nil

    private let workoutService = WorkoutService()
    private let blockService = BlockService()

    private func loadData() async {
        isLoading = true
        error = nil

        do {
            // Get blocks for this workout
            let blockData = try await workoutService.getBlocksWithWorkoutInfo(for: workout.id)

            // For each block, get its exercises
            var blockExercisesData: [Int: [(exercise: Exercise, blockExercise: BlockExercise)]] = [:]

            for (block, _) in blockData {
                let exercisesWithInfo = try await blockService.getExercisesWithBlockInfo(for: block.id)
                blockExercisesData[block.id] = exercisesWithInfo
            }

            await MainActor.run {
                self.blockData = blockData
                self.blockExercisesData = blockExercisesData
                self.isLoading = false
                print("DEBUG: Loaded \(blockData.count) blocks for workout \(workout.id)")
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
        ScrollView {
            VStack(spacing: 20) {
                // Workout Header
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text(workout.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let description = workout.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    HStack(spacing: 20) {
                        if let duration = workout.estimatedDurationMinutes {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Duración Estimada")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(duration) minutos")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dificultad")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(workout.difficultyLevel.rawValue.capitalized)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Blocks Section
                VStack(spacing: 16) {
                    Text("Bloques del Entrenamiento")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Cargando bloques...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error al cargar bloques")
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
                        .padding(.horizontal)
                    } else if blockData.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No hay bloques en este entrenamiento")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        ForEach(blockData.sorted(by: { $0.workoutBlock.orderInWorkout < $1.workoutBlock.orderInWorkout }), id: \.workoutBlock.id) { blockData in
                            if let exercisesWithInfo = blockExercisesData[blockData.block.id] {
                                BlockDisclosureGroup(block: blockData.block, exercisesWithInfo: exercisesWithInfo, selectedExercise: $selectedExercise)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(workout.name)
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

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: 1,
            name: "Entrenamiento de Fuerza",
            description: "Entrenamiento completo de fuerza",
            estimatedDurationMinutes: 60,
            difficultyLevel: .intermediate,
            workoutType: "Fuerza",
            isTemplate: true,
            createdBy: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        NavigationView {
            WorkoutDetailView(workout: mockWorkout)
        }
    }
}
