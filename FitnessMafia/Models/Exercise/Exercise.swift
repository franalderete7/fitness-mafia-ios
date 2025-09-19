//
//  Exercise.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct Exercise: BaseModel, Sendable {
    let id: Int
    let name: String
    let description: String?
    let videoUrl: String?
    let imageUrl: String?
    let categoryId: Int?
    let muscleGroups: [String]
    let equipmentNeeded: [String]
    let difficultyLevel: DifficultyLevel
    let defaultDurationSeconds: Int?
    let createdBy: Int
    let createdAt: Date
    let updatedAt: Date

    nonisolated enum CodingKeys: String, CodingKey {
        case id = "exercise_id"
        case name, description
        case videoUrl = "video_url"
        case imageUrl = "image_url"
        case categoryId = "category_id"
        case muscleGroups = "muscle_groups"
        case equipmentNeeded = "equipment_needed"
        case difficultyLevel = "difficulty_level"
        case defaultDurationSeconds = "default_duration_seconds"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
