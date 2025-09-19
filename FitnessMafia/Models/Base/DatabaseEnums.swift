//
//  DatabaseEnums.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation
import Supabase

enum UserRole: String, Codable, CaseIterable, Sendable {
    case admin
    case user
}

enum DifficultyLevel: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
}

enum BlockType: String, Codable, CaseIterable, Sendable {
    case warmup
    case main
    case cooldown
    case superset
    case circuit
    case standard
}

enum WorkoutType: String, Codable, CaseIterable, Sendable {
    case strength
    case cardio
    case hybrid
    case mobility
    case other
}

enum ProgramType: String, Codable, CaseIterable, Sendable {
    case strength
    case weightLoss = "weight_loss"
    case muscleGain = "muscle_gain"
    case endurance
    case other
}

enum DayOfWeek: Int, Codable, CaseIterable, Sendable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

/// Database operation errors
enum DatabaseError: LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case notFound(String)
    case unauthorized
    case validationError(String)
    case duplicateEntry(String)
    case supabaseError(PostgrestError)
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        case .notFound(let resource):
            return "\(resource) not found"
        case .unauthorized:
            return "Unauthorized access"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .duplicateEntry(let field):
            return "Duplicate entry for \(field)"
        case .supabaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Check your internet connection and try again"
        case .notFound:
            return "The requested item may have been deleted"
        case .unauthorized:
            return "Please log in and try again"
        case .validationError:
            return "Please check your input and try again"
        case .duplicateEntry:
            return "An item with this information already exists"
        default:
            return "Please try again or contact support"
        }
    }
}


