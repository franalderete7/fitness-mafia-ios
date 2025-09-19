//
//  SupabaseConfig.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import Foundation
import Supabase

/// Configuration for Supabase client
final class SupabaseConfig {
    /// Shared singleton instance
    static let shared = SupabaseConfig()

    /// Supabase client instance
    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://whjbyzeaiwnsxxsexiir.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndoamJ5emVhaXduc3h4c2V4aWlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMjcxMTMsImV4cCI6MjA3MzgwMzExM30.lpupMrPWsLWeHk_VPsPid6181g-qDXjHQ0D88Vn21WY"

        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }

    // TODO: Add authentication properties when auth is implemented
    // For now, we only need the Supabase client for database operations
}
