//
//  ProgramDetailView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

// Extension to add computed properties to ProgramWorkout for display
extension ProgramWorkout {
    var dayOfWeekSpanish: String {
        switch dayOfWeek {
        case .monday: return "Lunes"
        case .tuesday: return "Martes"
        case .wednesday: return "Miércoles"
        case .thursday: return "Jueves"
        case .friday: return "Viernes"
        case .saturday: return "Sábado"
        case .sunday: return "Domingo"
        }
    }

    var weekDayDisplay: String {
        "Semana \(weekNumber) - \(dayOfWeekSpanish)"
    }
}

struct WorkoutCard: View {
    let workout: Workout
    let programWorkout: ProgramWorkout

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    if let description = workout.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    Text(programWorkout.weekDayDisplay)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                if let duration = workout.estimatedDurationMinutes {
                    Label("\(duration) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Label(workout.difficultyLevel.rawValue.capitalized, systemImage: "chart.bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ProgramDetailView: View {
    let program: Program
    @State private var workoutData: [(workout: Workout, programWorkout: ProgramWorkout)] = []
    @State private var isLoading = true
    @State private var error: DatabaseError?

    private let programService = ProgramService()

    private func loadData() async {
        isLoading = true
        error = nil

        do {
            let workoutData = try await programService.getWorkoutsWithProgramInfo(for: program.id)
            await MainActor.run {
                self.workoutData = workoutData
                self.isLoading = false
                print("DEBUG: Loaded \(workoutData.count) workouts for program \(program.id)")
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
                // Program Header
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text(program.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let description = program.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duración")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(program.formattedDuration)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dificultad")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(program.difficultySpanish)
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

                // Workouts Section
                VStack(spacing: 16) {
                    Text("Entrenamientos del Programa")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Cargando entrenamientos...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error al cargar entrenamientos")
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
                    } else if workoutData.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No hay entrenamientos en este programa")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        ForEach(workoutData, id: \.programWorkout.id) { workoutData in
                            NavigationLink(destination: WorkoutDetailView(workout: workoutData.workout)) {
                                WorkoutCard(workout: workoutData.workout, programWorkout: workoutData.programWorkout)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .task {
            await loadData()
        }
    }
}

struct ProgramDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockProgram = Program(
            id: 1,
            name: "Programa de Fuerza",
            description: "Programa completo para ganar fuerza",
            durationWeeks: 8,
            difficultyLevel: .intermediate,
            programType: "Fuerza",
            isTemplate: true,
            createdBy: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        NavigationView {
            ProgramDetailView(program: mockProgram)
        }
    }
}
