//
//  BlockExercise.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct BlockExerciseID: Hashable, Codable, Sendable {
    let blockId: Int
    let exerciseId: Int

    enum CodingKeys: String, CodingKey {
        case blockId = "block_id"
        case exerciseId = "exercise_id"
    }
}

nonisolated struct BlockExercise: BaseModel, Sendable {
    let id: BlockExerciseID
    let orderInBlock: Int
    let sets: Int?
    let repetitions: Int?
    let restSeconds: Int?
    let weightKg: Decimal?
    let durationSeconds: Int?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date

    nonisolated enum CodingKeys: String, CodingKey {
        case blockId = "block_id"
        case exerciseId = "exercise_id"
        case orderInBlock = "order_in_block"
        case sets, repetitions
        case restSeconds = "rest_seconds"
        case weightKg = "weight_kg"
        case durationSeconds = "duration_seconds"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let blockId = try c.decode(Int.self, forKey: .blockId)
        let exerciseId = try c.decode(Int.self, forKey: .exerciseId)
        self.id = BlockExerciseID(blockId: blockId, exerciseId: exerciseId)
        self.orderInBlock = try c.decode(Int.self, forKey: .orderInBlock)
        self.sets = try c.decodeIfPresent(Int.self, forKey: .sets)
        self.repetitions = try c.decodeIfPresent(Int.self, forKey: .repetitions)
        self.restSeconds = try c.decodeIfPresent(Int.self, forKey: .restSeconds)
        self.weightKg = try c.decodeIfPresent(Decimal.self, forKey: .weightKg)
        self.durationSeconds = try c.decodeIfPresent(Int.self, forKey: .durationSeconds)
        self.notes = try c.decodeIfPresent(String.self, forKey: .notes)
        self.createdAt = try c.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try c.decode(Date.self, forKey: .updatedAt)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id.blockId, forKey: .blockId)
        try c.encode(id.exerciseId, forKey: .exerciseId)
        try c.encode(orderInBlock, forKey: .orderInBlock)
        try c.encodeIfPresent(sets, forKey: .sets)
        try c.encodeIfPresent(repetitions, forKey: .repetitions)
        try c.encodeIfPresent(restSeconds, forKey: .restSeconds)
        try c.encodeIfPresent(weightKg, forKey: .weightKg)
        try c.encodeIfPresent(durationSeconds, forKey: .durationSeconds)
        try c.encodeIfPresent(notes, forKey: .notes)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
    }
}


