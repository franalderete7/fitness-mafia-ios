//
//  BlockService.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import Foundation
import Supabase

final class BlockService: SupabaseService, CrudService {
    typealias Model = Block
    let tableName = "blocks"

    func fetchAll() async throws -> [Block] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Block] = try await self.client
                    .from(self.tableName)
                    .select()
                    .execute()
                    .value
                return response
            }
        }.value
    }

    func fetch(by id: Int) async throws -> Block {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Block] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("block_id", value: id)
                    .execute()
                    .value
                guard let block = response.first else {
                    throw DatabaseError.notFound("Block with id \(id) not found")
                }
                return block
            }
        }.value
    }

    // Get block exercises for a specific block
    func getBlockExercises(for blockId: Int) async throws -> [BlockExercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [BlockExercise] = try await self.client
                    .from("block_exercises")
                    .select()
                    .eq("block_id", value: blockId)
                    .order("order_in_block", ascending: true)
                    .execute()
                    .value
                return response
            }
        }.value
    }

    // Get exercises with block exercise info for a block
    func getExercisesWithBlockInfo(for blockId: Int) async throws -> [(exercise: Exercise, blockExercise: BlockExercise)] {
        try await Task.detached {
            try await self.executeQuery {
                // First get block exercises
                let blockExercises: [BlockExercise] = try await self.client
                    .from("block_exercises")
                    .select()
                    .eq("block_id", value: blockId)
                    .order("order_in_block", ascending: true)
                    .execute()
                    .value

                // Get unique exercise IDs
                let exerciseIds = Array(Set(blockExercises.map { $0.id.exerciseId }))

                // Fetch exercises
                let exercises: [Exercise] = try await self.client
                    .from("exercises")
                    .select()
                    .in("exercise_id", values: exerciseIds)
                    .execute()
                    .value

                // Create dictionary for quick lookup
                let exerciseDict = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })

                // Combine results
                return blockExercises.compactMap { blockExercise in
                    guard let exercise = exerciseDict[blockExercise.id.exerciseId] else { return nil }
                    return (exercise: exercise, blockExercise: blockExercise)
                }
            }
        }.value
    }

    // MARK: - CRUD Methods (not implemented for now)
    func create(_ model: Block) async throws -> Block {
        throw DatabaseError.unknownError(NSError(domain: "BlockService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Create not implemented"]))
    }

    func update(_ model: Block) async throws -> Block {
        throw DatabaseError.unknownError(NSError(domain: "BlockService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Update not implemented"]))
    }

    func delete(_ id: Int) async throws {
        throw DatabaseError.unknownError(NSError(domain: "BlockService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Delete not implemented"]))
    }
}
