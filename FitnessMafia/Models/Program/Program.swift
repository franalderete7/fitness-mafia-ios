//
//  Program.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct Program: BaseModel, Sendable {
    let id: Int
    let name: String
    let description: String?
    let durationWeeks: Int
    let difficultyLevel: DifficultyLevel
    let programType: String?
    let isTemplate: Bool
    let createdBy: Int
    let createdAt: Date
    let updatedAt: Date

    nonisolated enum CodingKeys: String, CodingKey {
        case id = "program_id"
        case name, description
        case durationWeeks = "duration_weeks"
        case difficultyLevel = "difficulty_level"
        case programType = "program_type"
        case isTemplate = "is_template"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

nonisolated struct ProgramWorkout: BaseModel, Sendable {
    let id: Int
    let programId: Int
    let workoutId: Int
    let weekNumber: Int
    let dayOfWeek: DayOfWeek
    let isRestDay: Bool
    let notes: String?
    let createdAt: Date
    var updatedAt: Date { createdAt }

    nonisolated enum CodingKeys: String, CodingKey {
        case id = "program_workout_id"
        case programId = "program_id"
        case workoutId = "workout_id"
        case weekNumber = "week_number"
        case dayOfWeek = "day_of_week"
        case isRestDay = "is_rest_day"
        case notes
        case createdAt = "created_at"
    }
}


