//
//  CrudService.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import Foundation

/// Base protocol for CRUD operations
protocol CrudService {
    associatedtype Model: BaseModel

    /// Fetch all records
    func fetchAll() async throws -> [Model]

    /// Fetch a single record by ID
    func fetch(by id: Model.ID) async throws -> Model

    /// Create a new record
    func create(_ model: Model) async throws -> Model

    /// Update an existing record
    func update(_ model: Model) async throws -> Model

    /// Delete a record by ID
    func delete(_ id: Model.ID) async throws
}

/// Extension with convenience methods
extension CrudService {
    /// Fetch multiple records by IDs
    func fetch(by ids: [Model.ID]) async throws -> [Model] {
        var results: [Model] = []
        for id in ids {
            let model = try await fetch(by: id)
            results.append(model)
        }
        return results
    }

    /// Check if a record exists
    func exists(_ id: Model.ID) async throws -> Bool {
        do {
            _ = try await fetch(by: id)
            return true
        } catch {
            return false
        }
    }
}

/// Protocol for services that support pagination
protocol PagedService: CrudService {
    /// Fetch records with pagination
    func fetch(page: Int, pageSize: Int) async throws -> [Model]

    /// Fetch records with filtering
    func fetch(where filter: [String: Any]) async throws -> [Model]
}

/// Protocol for services that support real-time subscriptions
protocol RealtimeService: CrudService {
    /// Subscribe to changes for all records
    func subscribeToAll() -> AsyncStream<Result<[Model], Error>>

    /// Subscribe to changes for a specific record
    func subscribe(to id: Model.ID) -> AsyncStream<Result<Model, Error>>

    /// Subscribe to changes with filter
    func subscribe(where filter: [String: Any]) -> AsyncStream<Result<[Model], Error>>
}
