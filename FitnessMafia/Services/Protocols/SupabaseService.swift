//
//  SupabaseService.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import Foundation
import Supabase

/// Base protocol for Supabase-powered services
protocol SupabaseService {
    /// The table name in Supabase
    var tableName: String { get }

    /// The Supabase client instance
    var client: SupabaseClient { get }
}

/// Extension with common Supabase operations
extension SupabaseService {
    var client: SupabaseClient {
        SupabaseConfig.shared.client
    }

    /// Execute a query with error handling
    func executeQuery<T>(_ query: @escaping () async throws -> T) async throws -> T {
        do {
            return try await query()
        } catch let error as PostgrestError {
            throw DatabaseError.supabaseError(error)
        } catch let error as URLError {
            throw DatabaseError.networkError(error)
        } catch {
            throw DatabaseError.unknownError(error)
        }
    }
}

/// Extension for CRUD operations using Supabase
extension SupabaseService where Self: CrudService, Model.ID == Int {
    /// Default implementation for fetching by ID
    func fetch(by id: Model.ID) async throws -> Model {
        try await executeQuery {
            let response: [Model] = try await self.client
                .from(self.tableName)
                .select()
                .eq("id", value: id)
                .execute()
                .value

            guard let model = response.first else {
                throw DatabaseError.notFound("Record with id \(id) not found")
            }

            return model
        }
    }

    /// Default implementation for updating records
    func update(_ model: Model) async throws -> Model where Model.ID == Int {
        try await executeQuery {
            let response: [Model] = try await self.client
                .from(self.tableName)
                .update(model)
                .eq("id", value: model.id)
                .select()
                .execute()
                .value

            guard let updatedModel = response.first else {
                throw DatabaseError.notFound("Record with id \(model.id) not found")
            }

            return updatedModel
        }
    }

    /// Default implementation for deleting records
    func delete(_ id: Model.ID) async throws where Model.ID == Int {
        try await executeQuery {
            try await self.client
                .from(self.tableName)
                .delete()
                .eq("id", value: id)
                .execute()
        }
    }
}

/// Extension for services with composite primary keys
extension SupabaseService where Self: CrudService {
    /// Fetch by composite ID
    func fetch(by id: BlockExerciseID) async throws -> Model where Model.ID == BlockExerciseID {
        try await executeQuery {
            let response: [Model] = try await self.client
                .from(self.tableName)
                .select()
                .eq("block_id", value: id.blockId)
                .eq("exercise_id", value: id.exerciseId)
                .execute()
                .value

            guard let model = response.first else {
                throw DatabaseError.notFound("Record with composite id not found")
            }

            return model
        }
    }

    /// Delete by composite ID
    func delete(_ id: BlockExerciseID) async throws where Model.ID == BlockExerciseID {
        try await executeQuery {
            try await self.client
                .from(self.tableName)
                .delete()
                .eq("block_id", value: id.blockId)
                .eq("exercise_id", value: id.exerciseId)
                .execute()
        }
    }
}
