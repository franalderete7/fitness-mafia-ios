//
//  ProgramsView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

struct ProgramCard: View {
    let title: String
    let subtitle: String
    let duration: String
    let difficulty: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                Label(duration, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Label(difficulty, systemImage: "chart.bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ProgramsView: View {
    let mockPrograms = [
        (title: "Beginner Strength", subtitle: "Build foundational strength", duration: "8 weeks", difficulty: "Beginner", color: Color.blue),
        (title: "Advanced Hypertrophy", subtitle: "Maximize muscle growth", duration: "12 weeks", difficulty: "Advanced", color: Color.green),
        (title: "Fat Loss Program", subtitle: "Lose weight effectively", duration: "6 weeks", difficulty: "Intermediate", color: Color.orange),
        (title: "Powerlifting Prep", subtitle: "Increase your lifts", duration: "10 weeks", difficulty: "Advanced", color: Color.red),
        (title: "Mobility Focus", subtitle: "Improve flexibility", duration: "4 weeks", difficulty: "All Levels", color: Color.purple)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Training Programs")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Choose from our curated training programs designed to help you achieve your fitness goals.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)

                    // Programs List
                    VStack(spacing: 16) {
                        ForEach(mockPrograms, id: \.title) { program in
                            ProgramCard(
                                title: program.title,
                                subtitle: program.subtitle,
                                duration: program.duration,
                                difficulty: program.difficulty,
                                color: program.color
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.vertical)
            }
            .navigationTitle("Programs")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ProgramsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramsView()
    }
}
