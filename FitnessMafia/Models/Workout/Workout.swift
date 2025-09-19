//
//  Workout.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct Workout: BaseModel, Sendable {
    let id: Int
    let name: String
    let description: String?
    let estimatedDurationMinutes: Int?
    let difficultyLevel: DifficultyLevel
    let workoutType: String?
    let isTemplate: Bool
    let createdBy: Int
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "workout_id"
        case name, description
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case difficultyLevel = "difficulty_level"
        case workoutType = "workout_type"
        case isTemplate = "is_template"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct WorkoutBlockID: Hashable, Codable {
    let workoutId: Int
    let blockId: Int

    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case blockId = "block_id"
    }
}

struct WorkoutBlock: Codable, Identifiable, Hashable {
    var id: String { "\(workoutId)-\(blockId)" }
    let workoutId: Int
    let blockId: Int
    let orderInWorkout: Int
    let restAfterBlockSeconds: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case blockId = "block_id"
        case orderInWorkout = "order_in_workout"
        case restAfterBlockSeconds = "rest_after_block_seconds"
        case createdAt = "created_at"
    }
}


