//
//  ExerciseService.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import Foundation
import Supabase

/// Service for managing exercise data operations
final class ExerciseService: SupabaseService, CrudService {
    typealias Model = Exercise

    let tableName = "exercises"

    // MARK: - CRUD Operations
    func fetchAll() async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .execute()
                    .value
                return response
            }
        }.value
    }

    func fetch(by id: Int) async throws -> Exercise {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("exercise_id", value: id)
                    .execute()
                    .value

                guard let exercise = response.first else {
                    throw DatabaseError.notFound("Exercise with id \(id) not found")
                }

                return exercise
            }
        }.value
    }

    func create(_ exercise: Exercise) async throws -> Exercise {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .insert(exercise)
                    .select()
                    .execute()
                    .value

                guard let createdExercise = response.first else {
                    throw DatabaseError.unknownError(NSError(domain: "ExerciseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create exercise"]))
                }

                return createdExercise
            }
        }.value
    }

    func update(_ exercise: Exercise) async throws -> Exercise {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .update(exercise)
                    .eq("exercise_id", value: exercise.id)
                    .select()
                    .execute()
                    .value

                guard let updatedExercise = response.first else {
                    throw DatabaseError.notFound("Exercise with id \(exercise.id) not found")
                }

                return updatedExercise
            }
        }.value
    }

    func delete(_ id: Int) async throws {
        try await Task.detached { [client, tableName = self.tableName] in
            // No value to return; just perform the async call
            _ = try await client
                .from(tableName)
                .delete()
                .eq("exercise_id", value: id)
                .execute()
        }.value
    }

    // MARK: - Custom Exercise Operations

    /// Get exercises by category
    func getExercisesByCategory(_ categoryId: Int) async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("category_id", value: categoryId)
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Get exercises by difficulty
    func getExercisesByDifficulty(_ difficulty: DifficultyLevel) async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("difficulty_level", value: difficulty.rawValue)
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Get public exercises
    func getPublicExercises() async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("is_public", value: true)
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Get exercises created by user
    func getExercisesByCreator(_ userId: Int) async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("created_by", value: userId)
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Search exercises by name
    func searchExercises(query: String) async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .ilike("name", pattern: "%\(query)%")
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Get exercises containing specific muscle group
    func getExercisesByMuscleGroup(_ muscleGroup: String) async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .contains("muscle_groups", value: [muscleGroup])
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Get exercises by equipment
    func getExercisesByEquipment(_ equipment: String) async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .contains("equipment_needed", value: [equipment])
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Get exercises without equipment (bodyweight only)
    func getBodyweightExercises() async throws -> [Exercise] {
        try await Task.detached {
            try await self.executeQuery {
                let response: [Exercise] = try await self.client
                    .from(self.tableName)
                    .select()
                    .eq("equipment_needed", value: ["None"])
                    .execute()
                    .value

                return response
            }
        }.value
    }
}

// MARK: - Exercise Category Operations
extension ExerciseService {
    /// Get all exercise categories
    func getExerciseCategories() async throws -> [ExerciseCategory]? {
        try await Task.detached {
            try await self.executeQuery {
                let response: [ExerciseCategory] = try await self.client
                    .from("exercise_categories")
                    .select()
                    .execute()
                    .value

                return response
            }
        }.value
    }

    /// Get exercise category by ID
    func getExerciseCategory(_ id: Int) async throws -> ExerciseCategory? {
        try await Task.detached {
            try await self.executeQuery {
                let response: [ExerciseCategory] = try await self.client
                    .from("exercise_categories")
                    .select()
                    .eq("category_id", value: id)
                    .execute()
                    .value

                return response.first
            }
        }.value
    }
}
