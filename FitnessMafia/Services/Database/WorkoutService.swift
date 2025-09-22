//
//  WorkoutService.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import Foundation
import Supabase

final class WorkoutService: SupabaseService, CrudService {
    typealias Model = Workout
    let tableName = "workouts"

    func fetchAll() async throws -> [Workout] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Workout] = try await self.client
                    .from(self.tableName)
                    .select()
                    .execute()
                    .value
                return response
            }
        }.value
    }

    func fetch(by id: Int) async throws -> Workout {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Workout] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("workout_id", value: id)
                    .execute()
                    .value
                guard let workout = response.first else {
                    throw DatabaseError.notFound("Workout with id \(id) not found")
                }
                return workout
            }
        }.value
    }

    // Get workout blocks for a specific workout
    func getWorkoutBlocks(for workoutId: Int) async throws -> [WorkoutBlock] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [WorkoutBlock] = try await self.client
                    .from("workout_blocks")
                    .select()
                    .eq("workout_id", value: workoutId)
                    .order("order_in_workout", ascending: true)
                    .execute()
                    .value
                return response
            }
        }.value
    }

    // Get blocks with workout block info for a workout
    func getBlocksWithWorkoutInfo(for workoutId: Int) async throws -> [(block: Block, workoutBlock: WorkoutBlock)] {
        try await Task.detached {
            try await self.executeQuery {
                // First get workout blocks
                let workoutBlocks: [WorkoutBlock] = try await self.client
                    .from("workout_blocks")
                    .select()
                    .eq("workout_id", value: workoutId)
                    .order("order_in_workout", ascending: true)
                    .execute()
                    .value

                // Get unique block IDs
                let blockIds = Array(Set(workoutBlocks.map { $0.blockId }))

                // Fetch blocks
                let blocks: [Block] = try await self.client
                    .from("blocks")
                    .select()
                    .in("block_id", values: blockIds)
                    .execute()
                    .value

                // Create dictionary for quick lookup
                let blockDict = Dictionary(uniqueKeysWithValues: blocks.map { ($0.id, $0) })

                // Combine results
                return workoutBlocks.compactMap { workoutBlock in
                    guard let block = blockDict[workoutBlock.blockId] else { return nil }
                    return (block: block, workoutBlock: workoutBlock)
                }
            }
        }.value
    }

    // MARK: - CRUD Methods (not implemented for now)
    func create(_ model: Workout) async throws -> Workout {
        throw DatabaseError.unknownError(NSError(domain: "WorkoutService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Create not implemented"]))
    }

    func update(_ model: Workout) async throws -> Workout {
        throw DatabaseError.unknownError(NSError(domain: "WorkoutService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Update not implemented"]))
    }

    func delete(_ id: Int) async throws {
        throw DatabaseError.unknownError(NSError(domain: "WorkoutService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Delete not implemented"]))
    }
}
