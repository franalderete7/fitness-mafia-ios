//
//  BaseModel.swift
//  FitnessMafia
//
//  Generated on 2025-09-18
//

import Foundation

protocol BaseModel: Codable, Identifiable, Hashable, Sendable {
    var createdAt: Date { get }
    var updatedAt: Date { get }
}
