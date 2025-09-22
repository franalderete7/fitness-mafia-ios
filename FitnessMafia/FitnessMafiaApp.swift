//
//  FitnessMafiaApp.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

@main
struct FitnessMafiaApp: App {
    @StateObject private var authManager = AuthManager()
    @State private var animationComplete = false

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
                    LaunchScreenViewControllerRepresentable(animationComplete: $animationComplete)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
    }
}
