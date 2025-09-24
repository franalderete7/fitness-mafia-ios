//
//  User.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

nonisolated struct User: BaseModel, Sendable {
    let id: Int
    let appUserId: String
    let username: String
    let email: String
    let role: UserRole
    let firstName: String?
    let lastName: String?
    let imageUrl: String?
    let isActive: Bool
    let isPremium: Bool
    let premiumExpiresAt: Date?
    let premiumWillRenew: Bool?
    let createdAt: Date
    let updatedAt: Date

    var displayName: String { [firstName, lastName].compactMap { $0 }.joined(separator: " ").isEmpty ? username : [firstName, lastName].compactMap { $0 }.joined(separator: " ") }

    nonisolated enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case appUserId = "app_user_id"
        case username, email, role
        case firstName = "first_name"
        case lastName = "last_name"
        case imageUrl = "image_url"
        case isActive = "is_active"
        case isPremium = "is_premium"
        case premiumExpiresAt = "premium_expires_at"
        case premiumWillRenew = "premium_will_renew"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


