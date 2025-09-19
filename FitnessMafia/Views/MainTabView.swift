//
//  MainTabView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProgramsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "calendar.circle.fill" : "calendar")
                        Text("Programas")
                    }
                }
                .tag(0)

            ExercisesView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "figure.strengthtraining.traditional.circle.fill" : "figure.strengthtraining.traditional")
                        Text("Ejercicios")
                    }
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "person.circle.fill" : "person.circle")
                        Text("Perfil")
                    }
                }
                .tag(2)
        }
        .accentColor(.blue)
        .tabViewStyle(.automatic)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
