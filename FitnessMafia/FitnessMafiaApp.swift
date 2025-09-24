//
//  FitnessMafiaApp.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI
import RevenueCat

@main
struct FitnessMafiaApp: App {
    @StateObject private var authManager = AuthManager()
    @State private var animationComplete = false

    init() {
        Purchases.logLevel = .debug
        // If we already have a persisted app user id, configure with it; otherwise anonymous
        if let storedAppUserId = UserDefaults.standard.string(forKey: "app_user_id") {
            Purchases.configure(withAPIKey: "appl_YPPiQFdSfQnpFwHUhbHmwvDKtcs", appUserID: storedAppUserId)
        } else {
            Purchases.configure(withAPIKey: "appl_YPPiQFdSfQnpFwHUhbHmwvDKtcs")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
                if !animationComplete {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .zIndex(1)
                    LaunchScreenViewControllerRepresentable(animationComplete: $animationComplete)
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
        }
    }
}
