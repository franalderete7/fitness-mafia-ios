//
//  User.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct User: BaseModel, Sendable {
    let id: Int
    let username: String
    let email: String
    let role: UserRole
    let firstName: String?
    let lastName: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    var displayName: String { [firstName, lastName].compactMap { $0 }.joined(separator: " ").isEmpty ? username : [firstName, lastName].compactMap { $0 }.joined(separator: " ") }

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username, email, role
        case firstName = "first_name"
        case lastName = "last_name"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


