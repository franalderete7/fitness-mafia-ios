//
//  ExerciseDetailView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI
import AVKit
import Combine

// Extension to add computed properties to Exercise for detail view
extension Exercise {
    var repsSuggestion: String {
        switch difficultyLevel {
        case .beginner: return "3 series de 10-15 repeticiones"
        case .intermediate: return "4 series de 8-12 repeticiones"
        case .advanced: return "4-5 series de 6-8 repeticiones"
        }
    }

    var restTimeSuggestion: String {
        switch difficultyLevel {
        case .beginner: return "60-90 segundos"
        case .intermediate: return "90-120 segundos"
        case .advanced: return "120-180 segundos"
        }
    }

    var weightSuggestion: String? {
        switch equipmentNeeded.first {
        case "Barbell", "Dumbbells":
            switch difficultyLevel {
            case .beginner: return "Peso ligero a moderado"
            case .intermediate: return "Peso moderado a pesado"
            case .advanced: return "Peso pesado"
            }
        default: return nil
        }
    }

    // Localized difficulty in Spanish
    var difficultySpanish: String {
        switch difficultyLevel {
        case .beginner: return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced: return "Avanzado"
        }
    }

    // Localized category name by id (fallback handled where used)
    var categoryNameSpanishDetail: String {
        switch categoryId {
        case 1: return "Pecho"
        case 2: return "Espalda"
        case 3: return "Piernas"
        case 4: return "Hombros"
        case 5: return "Brazos"
        case 6: return "Core"
        case 7: return "Cardio"
        case 8: return "Cuerpo Completo"
        default: return "Otro"
        }
    }

    // Translate equipment names from English to Spanish
    var translatedEquipment: [String] {
        equipmentNeeded.map { equipment in
            switch equipment.lowercased() {
            case "dumbbells": return "Mancuernas"
            case "barbell": return "Barra"
            case "bench": return "Banco"
            case "cable machine": return "Máquina de poleas"
            case "resistance bands": return "Bandas elásticas"
            case "kettlebell": return "Kettlebell"
            case "pull-up bar": return "Barra de dominadas"
            case "medicine ball": return "Bola medicinal"
            case "none", "bodyweight", "body weight": return "Sin equipo"
            default: return equipment // Keep original if no translation found
            }
        }
    }

    // Translate muscle group names from English to Spanish
    var translatedMuscleGroups: [String] {
        muscleGroups.map { muscle in
            switch muscle.lowercased() {
            case "chest": return "Pecho"
            case "back": return "Espalda"
            case "shoulders": return "Hombros"
            case "biceps": return "Bíceps"
            case "triceps": return "Tríceps"
            case "legs": return "Piernas"
            case "quadriceps": return "Cuádriceps"
            case "hamstrings": return "Isquiotibiales"
            case "calves": return "Pantorrillas"
            case "glutes": return "Glúteos"
            case "core": return "Core"
            case "abs": return "Abdominales"
            case "forearms": return "Antebrazos"
            case "traps": return "Trapecios"
            case "lats": return "Dorsales"
            default: return muscle // Keep original if no translation found
            }
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State var player = AVPlayer()
    @State var isPlaying = false
    @State var isVideoReady = false
    @State private var cancellables = Set<AnyCancellable>()
    
    init(exercise: Exercise) {
        self.exercise = exercise
        configureAudioSession()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // Video Player - takes 1/3.5 of screen height
                if isVideoReady {
                    FullScreenVideoPlayer(player: player)
                        .frame(height: geometry.size.height / 3.5)
                } else {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height / 3.5)
                        .background(Color.black)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
                
                // Exercise Information - takes remaining space
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(exercise.name)
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 1) {
                            Text(exercise.repsSuggestion)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .font(.system(size: 13))
                            
                            Text(" - descanso \(exercise.restTimeSuggestion)")
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 2) {
                            Text("Dificultad")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(exercise.difficultySpanish.uppercased())
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 4)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white)
                                    .background(Color.black)
                                    .cornerRadius(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 2)
                        }
                        .padding(.top, 10)
                        
                        if !exercise.translatedEquipment.isEmpty {
                            VStack(spacing: 2) {
                                Text("Equipos")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                                    ForEach(exercise.translatedEquipment, id: \.self) { equipment in
                                        Text(equipment.uppercased())
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 4)
                                            .font(.system(size: 11))
                                            .foregroundColor(.white)
                                            .background(Color.black)
                                            .cornerRadius(4)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                }
                                .padding(.top, 2)
                            }
                            .padding(.top, 10)
                        }
                        
                        VStack(spacing: 2) {
                            Text("Grupos musculares")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                                ForEach(exercise.translatedMuscleGroups, id: \.self) { muscle in
                                    Text(muscle.uppercased())
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 4)
                                        .font(.system(size: 11))
                                        .foregroundColor(.white)
                                        .background(Color.black)
                                        .cornerRadius(4)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                            }
                            .padding(.top, 2)
                        }
                        .padding(.top, 10)
                        
                        VStack(spacing: 2) {
                            Text("Categoría")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(exercise.categoryNameSpanish.uppercased())
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 4)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white)
                                    .background(Color.black)
                                    .cornerRadius(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 2)
                        }
                        .padding(.top, 10)
                        
                        if let weight = exercise.weightSuggestion {
                            VStack(spacing: 2) {
                                Text("Peso")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(weight.uppercased())
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 4)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white)
                                    .background(Color.black)
                                    .cornerRadius(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                            }
                            .padding(.top, 10)
                        }
                        
                        if let description = exercise.description, !description.isEmpty {
                            VStack(spacing: 2) {
                                Text("Descripción")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(description)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                            }
                            .padding(.top, 10)
                        }
                        
                        Spacer() // Fill remaining space
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                }
            }
            .frame(maxHeight: geometry.size.height)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom) // Ensure full screen coverage
            .onAppear {
                checkVideoCache()
                self.player.play()
                self.isPlaying = true
                setupVideoPlaybackObserver()
            }
            .onDisappear {
                cancellables.removeAll()
                self.player.seek(to: .zero)
                self.player.pause()
                self.isPlaying = false
            }
            .onReceive(player.publisher(for: \.status)) { status in
                if status == .readyToPlay {
                    isVideoReady = true
                }
            }
        }
    }

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func setupVideoPlaybackObserver() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            .sink { _ in
                self.player.seek(to: .zero)
                self.player.play()
            }
            .store(in: &cancellables)
    }

    private func getVideoFileUrl() -> URL? {
        guard let videoUrl = exercise.videoUrl else {
            print("exercise.videoUrl is nil")
            return nil
        }

        let videoFileUrl = URL(string: videoUrl)
        guard videoFileUrl != nil else {
            print("Invalid video URL")
            return nil
        }

        let videoFilename = "\(exercise.name).mp4"
        let saveUrl = FileManager.default.temporaryDirectory.appendingPathComponent(videoFilename)
        return saveUrl
    }

    private func downloadVideoToCache(from url: URL, saveTo saveUrl: URL) {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { (location, _, _) in
            if let location = location {
                do {
                    try FileManager.default.moveItem(at: location, to: saveUrl)
                    DispatchQueue.main.async {
                        self.player = AVPlayer(url: saveUrl)
                        self.isVideoReady = true
                        self.player.play()
                    }
                    print("Video successfully cached at: \(saveUrl)")
                } catch {
                    print("Failed to move video file to cache directory: \(error)")
                }
            }
        }
        downloadTask.resume()
    }

    func checkVideoCache() {
        guard let videoFileUrl = getVideoFileUrl() else {
            print("Video file URL could not be generated.")
            return
        }
        let cachedVideoUrl = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(videoFileUrl.lastPathComponent)

        if cachedVideoUrl.isFileURL && FileManager.default.fileExists(atPath: cachedVideoUrl.path) {
            self.player = AVPlayer(url: cachedVideoUrl)
            self.isVideoReady = true
            print("Serving video from cache")
        } else {
            guard let videoUrlString = exercise.videoUrl, let videoUrl = URL(string: videoUrlString) else {
                print("Invalid video URL")
                return
            }
            downloadVideoToCache(from: videoUrl, saveTo: cachedVideoUrl)
            print("Serving video from URL")
        }
    }
    
    
    struct FullScreenVideoPlayer: UIViewControllerRepresentable {
        var player: AVPlayer
        
        func makeUIViewController(context: Context) -> AVPlayerViewController {
            let controller = AVPlayerViewController()
            controller.player = player
            controller.videoGravity = .resizeAspectFill
            controller.showsPlaybackControls = false
            controller.player?.isMuted = true // Mute the video here
            return controller
        }
        
        func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
            uiViewController.player = player
        }
    }
    
    
    struct ExerciseDetailView_Previews: PreviewProvider {
        static var previews: some View {
            let mockExercise = Exercise(
                id: 1,
                name: "Push-ups",
                description: "A classic bodyweight exercise that targets the chest, shoulders, and triceps. Perfect for building upper body strength.",
                videoUrl: nil,
                imageUrl: nil,
                categoryId: 1,
                muscleGroups: ["Chest", "Shoulders", "Triceps"],
                equipmentNeeded: ["None"],
                difficultyLevel: .beginner,
                defaultDurationSeconds: 45,
                createdBy: 1,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            ExerciseDetailView(exercise: mockExercise)
        }
    }
}
