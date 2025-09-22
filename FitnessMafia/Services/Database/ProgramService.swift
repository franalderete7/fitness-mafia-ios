//
//  ProgramService.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import Foundation
import Supabase

final class ProgramService: SupabaseService, CrudService {
    typealias Model = Program
    let tableName = "programs"

    func fetchAll() async throws -> [Program] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Program] = try await self.client
                    .from(self.tableName)
                    .select()
                    .execute()
                    .value
                return response
            }
        }.value
    }

    func fetch(by id: Int) async throws -> Program {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Program] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("program_id", value: id)
                    .execute()
                    .value
                guard let program = response.first else {
                    throw DatabaseError.notFound("Program with id \(id) not found")
                }
                return program
            }
        }.value
    }

    // Get program workouts for a specific program
    func getProgramWorkouts(for programId: Int) async throws -> [ProgramWorkout] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [ProgramWorkout] = try await self.client
                    .from("program_workouts")
                    .select()
                    .eq("program_id", value: programId)
                    .order("week_number", ascending: true)
                    .order("day_of_week", ascending: true)
                    .execute()
                    .value
                return response
            }
        }.value
    }

    // Get workouts with program workout info for a program
    func getWorkoutsWithProgramInfo(for programId: Int) async throws -> [(workout: Workout, programWorkout: ProgramWorkout)] {
        try await Task.detached {
            try await self.executeQuery {
                // First get program workouts
                let programWorkouts: [ProgramWorkout] = try await self.client
                    .from("program_workouts")
                    .select()
                    .eq("program_id", value: programId)
                    .order("week_number", ascending: true)
                    .order("day_of_week", ascending: true)
                    .execute()
                    .value

                // Get unique workout IDs
                let workoutIds = Array(Set(programWorkouts.map { $0.workoutId }))

                // Fetch workouts
                let workouts: [Workout] = try await self.client
                    .from("workouts")
                    .select()
                    .in("workout_id", values: workoutIds)
                    .execute()
                    .value

                // Create dictionary for quick lookup
                let workoutDict = Dictionary(uniqueKeysWithValues: workouts.map { ($0.id, $0) })

                // Combine results
                return programWorkouts.compactMap { programWorkout in
                    guard let workout = workoutDict[programWorkout.workoutId] else { return nil }
                    return (workout: workout, programWorkout: programWorkout)
                }
            }
        }.value
    }

    // MARK: - CRUD Methods (not implemented for now)
    func create(_ model: Program) async throws -> Program {
        throw DatabaseError.unknownError(NSError(domain: "ProgramService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Create not implemented"]))
    }

    func update(_ model: Program) async throws -> Program {
        throw DatabaseError.unknownError(NSError(domain: "ProgramService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Update not implemented"]))
    }

    func delete(_ id: Int) async throws {
        throw DatabaseError.unknownError(NSError(domain: "ProgramService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Delete not implemented"]))
    }
}
