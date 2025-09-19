//
//  ExerciseDetailView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI
import AVKit

// Extension to add computed properties to Exercise for detail view
extension Exercise {
    var repsSuggestion: String {
        switch difficultyLevel {
        case .beginner: return "3 sets of 10-15 reps"
        case .intermediate: return "4 sets of 8-12 reps"
        case .advanced: return "4-5 sets of 6-8 reps"
        }
    }

    var restTimeSuggestion: String {
        switch difficultyLevel {
        case .beginner: return "60-90 seconds"
        case .intermediate: return "90-120 seconds"
        case .advanced: return "120-180 seconds"
        }
    }

    var weightSuggestion: String? {
        switch equipmentNeeded.first {
        case "Barbell", "Dumbbells":
            switch difficultyLevel {
            case .beginner: return "Light to moderate weight"
            case .intermediate: return "Moderate to heavy weight"
            case .advanced: return "Heavy weight"
            }
        default: return nil
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var isVideoLoading = true
    @State private var player: AVPlayer?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    videoSection
                    infoCard
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    @ViewBuilder private var videoSection: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(height: UIScreen.main.bounds.height / 3)
                .overlay(videoOverlay)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isVideoLoading = false
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    @ViewBuilder private var videoOverlay: some View {
        VStack {
            if isVideoLoading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            } else {
                Spacer()
                Text("Video Preview")
                    .foregroundColor(.white)
                    .font(.headline)
                Text("(Demo - Video would play here)")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
                Spacer()
            }
        }
    }

    @ViewBuilder private var infoCard: some View {
        VStack(spacing: 20) {
            titleAndBasics
            sections
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
        .padding(.horizontal, 16)
        .padding(.top, -8)
    }

    @ViewBuilder private var titleAndBasics: some View {
        VStack(spacing: 12) {
            Text(exercise.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("REPS")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(exercise.repsSuggestion)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 4) {
                    Text("REST TIME")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(exercise.restTimeSuggestion)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    @ViewBuilder private var sections: some View {
        VStack(spacing: 20) {
            difficultySection
            equipmentSection
            muscleSection
            categorySection
            weightSection
            descriptionSection
        }
    }

    @ViewBuilder private var difficultySection: some View {
        ExerciseDetailSection(title: "Difficulty Level") {
            HStack(spacing: 8) {
                Text(exercise.difficultyLevel.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(difficultyColor(for: exercise.difficultyLevel))
                    .cornerRadius(16)
            }
        }
    }

    @ViewBuilder private var equipmentSection: some View {
        if !exercise.equipmentNeeded.isEmpty {
            ExerciseDetailSection(title: "Equipment Needed") {
                HStack(spacing: 8) {
                    ForEach(exercise.equipmentNeeded, id: \.self) { equipment in
                        Text(equipment)
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    @ViewBuilder private var muscleSection: some View {
        ExerciseDetailSection(title: "Target Muscle Groups") {
            HStack(spacing: 8) {
                ForEach(exercise.muscleGroups, id: \.self) { muscle in
                    Text(muscle)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
    }

    @ViewBuilder private var categorySection: some View {
        ExerciseDetailSection(title: "Category") {
            HStack(spacing: 8) {
                Text(exercise.categoryName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(exercise.displayColor)
                    .cornerRadius(16)
            }
        }
    }

    @ViewBuilder private var weightSection: some View {
        if let weight = exercise.weightSuggestion {
            ExerciseDetailSection(title: "Recommended Weight") {
                HStack(spacing: 8) {
                    Text(weight)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
    }

    @ViewBuilder private var descriptionSection: some View {
        ExerciseDetailSection(title: "Description") {
            Text(exercise.description ?? "")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    private func difficultyColor(for level: DifficultyLevel) -> Color {
        switch level {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct ExerciseDetailSection<Content: View>: View {
    let title: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            content()
        }
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockExercise = Exercise(
            id: 1,
            name: "Push-ups",
            description: "A classic bodyweight exercise that targets the chest, shoulders, and triceps. Perfect for building upper body strength.",
            videoUrl: nil,
            imageUrl: nil,
            categoryId: 1,
            muscleGroups: ["Chest", "Shoulders", "Triceps"],
            equipmentNeeded: ["None"],
            difficultyLevel: .beginner,
            defaultDurationSeconds: 45,
            createdBy: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        ExerciseDetailView(exercise: mockExercise)
    }
}
