//
//  Block.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct Block: BaseModel, Sendable {
    let id: Int
    let name: String
    let description: String?
    let blockType: BlockType
    let restBetweenExercises: Int
    let createdBy: Int?
    let createdAt: Date
    let updatedAt: Date

    nonisolated enum CodingKeys: String, CodingKey {
        case id = "block_id"
        case name, description
        case blockType = "block_type"
        case restBetweenExercises = "rest_between_exercises"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


