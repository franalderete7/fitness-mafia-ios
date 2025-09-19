//
//  ProfileView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ProfileView: View {
    let userStats = [
        (title: "Workouts", value: "24", subtitle: "This month", color: Color.blue),
        (title: "Minutes", value: "1,248", subtitle: "Total time", color: Color.green),
        (title: "Streak", value: "7", subtitle: "Days", color: Color.orange)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                        }

                        VStack(spacing: 4) {
                            Text("Alex Johnson")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Fitness Enthusiast")
                                .foregroundColor(.secondary)
                            Text("Member since March 2024")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)

                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(userStats, id: \.title) { stat in
                            StatCard(
                                title: stat.title,
                                value: stat.value,
                                subtitle: stat.subtitle,
                                color: stat.color
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Menu Sections
                    VStack(spacing: 24) {
                        // Fitness Goals
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fitness Goals")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                ProfileMenuItem(title: "Weight Loss", subtitle: "Lose 5kg in 2 months", icon: "scalemass", color: .green)
                                ProfileMenuItem(title: "Strength Training", subtitle: "Increase bench press by 20kg", icon: "figure.strengthtraining.traditional", color: .blue)
                                ProfileMenuItem(title: "Cardio Endurance", subtitle: "Run 5km without stopping", icon: "figure.run", color: .orange)
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Settings & Preferences
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Settings")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                ProfileMenuItem(title: "Notifications", subtitle: "Workout reminders", icon: "bell", color: .purple)
                                ProfileMenuItem(title: "Privacy", subtitle: "Data sharing preferences", icon: "hand.raised", color: .gray)
                                ProfileMenuItem(title: "Units", subtitle: "kg, lbs, km, miles", icon: "ruler", color: .indigo)
                                ProfileMenuItem(title: "Theme", subtitle: "Light, Dark, System", icon: "moon", color: .yellow)
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Achievements
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Achievements")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    AchievementBadge(title: "First Workout", icon: "star.fill", color: .yellow, earned: true)
                                    AchievementBadge(title: "Week Streak", icon: "flame.fill", color: .orange, earned: true)
                                    AchievementBadge(title: "Marathon", icon: "figure.run", color: .green, earned: false)
                                    AchievementBadge(title: "Strength Master", icon: "dumbbell.fill", color: .blue, earned: false)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)

                    // Sign Out Button
                    Button(action: {
                        // Logout action would go here
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ProfileMenuItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let color: Color
    let earned: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(earned ? color.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(earned ? color : .gray)
                    .font(.title2)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(earned ? .primary : .secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
