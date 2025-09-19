//
//  ExerciseCategory.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct ExerciseCategory: BaseModel, Sendable {
    let id: Int
    let name: String
    let description: String?
    let createdAt: Date
    var updatedAt: Date { createdAt }

    nonisolated enum CodingKeys: String, CodingKey {
        case id = "category_id"
        case name, description
        case createdAt = "created_at"
    }
}


