//
//  ExerciseDetailView.swift
//  FitnessMafia
//
//  Created by Francisco Alderete on 18/09/2025.
//

import SwiftUI
import AVKit
import AVFoundation
import Combine

// Extension to add computed properties to Exercise for detail view
extension Exercise {
    // Format default duration from schema field
    var formattedDefaultDuration: String? {
        guard let seconds = defaultDurationSeconds else { return nil }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 {
            return "\(minutes)min \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
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
        guard let categoryId = categoryId else { return "Otro" }
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
    @State private var overlayOpacity: Double = 1.0
    @State private var fadeInDuration: Double = 1.0
    @State private var fadeOutDuration: Double = 1.0
    @State private var fadeOutStarted: Bool = false
    @State private var timeObserverToken: Any?
    @State private var timeObserverOwner: AVPlayer?
    @State private var didSetupPlayback = false
    
    init(exercise: Exercise) {
        self.exercise = exercise
        configureAudioSession()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // Video Player - takes 1/3.5 of screen height
                if isVideoReady {
                    ZStack {
                        FullScreenVideoPlayer(player: player)
                        Rectangle()
                            .fill(Color.black)
                            .opacity(overlayOpacity)
                            .allowsHitTesting(false)
                    }
                    .frame(height: geometry.size.height / 3.5)
                } else {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height / 3.5)
                        .background(Color.black)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
                
                // Exercise Information - takes remaining space
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and meta
                        VStack(alignment: .leading, spacing: 6) {
                            Text(exercise.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            if let duration = exercise.formattedDefaultDuration {
                                Label("Duración por defecto: \(duration)", systemImage: "clock")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)

                        // Info card styled consistently
                        VStack(alignment: .leading, spacing: 16) {
                            // Difficulty
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Dificultad")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                                Text(exercise.difficultySpanish)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Equipment (comma separated)
                            if !exercise.translatedEquipment.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Equipos")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.semibold)
                                    Text(exercise.translatedEquipment.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            // Muscle groups (comma separated)
                            if !exercise.translatedMuscleGroups.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Grupos musculares")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.semibold)
                                    Text(exercise.translatedMuscleGroups.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            // Category
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Categoría")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                                Text(exercise.categoryNameSpanishDetail)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Description
                            if let description = exercise.description, !description.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Descripción")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.semibold)
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                }
            }
            .frame(maxHeight: geometry.size.height)
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom) // Ensure full screen coverage
            .onAppear {
                // Avoid double-adding observers when presenting quickly
                guard !didSetupPlayback else { return }
                didSetupPlayback = true
                checkVideoCache()
                self.player.play()
                self.isPlaying = true
                setupVideoPlaybackObserver()
                addPeriodicTimeObserver()
            }
            .onDisappear {
                cancellables.removeAll()
                self.player.seek(to: .zero)
                self.player.pause()
                self.isPlaying = false
                self.overlayOpacity = 1.0
                removePeriodicTimeObserver()
                didSetupPlayback = false
            }
            .onReceive(player.publisher(for: \.status)) { status in
                if status == .readyToPlay {
                    isVideoReady = true
                    withAnimation(.easeInOut(duration: fadeInDuration)) {
                        overlayOpacity = 0.0
                    }
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
                // Loop, reset fade-out state, and fade back in at restart
                self.player.seek(to: .zero)
                self.player.play()
                self.fadeOutStarted = false
                withAnimation(.easeInOut(duration: self.fadeInDuration)) {
                    self.overlayOpacity = 0.0
                }
            }
            .store(in: &cancellables)
    }

    private func addPeriodicTimeObserver() {
        removePeriodicTimeObserver()
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { currentTime in
            guard let item = self.player.currentItem else { return }
            let durationSeconds = CMTimeGetSeconds(item.duration)
            let currentSeconds = CMTimeGetSeconds(currentTime)
            guard durationSeconds.isFinite && durationSeconds > 0 else { return }
            let remaining = durationSeconds - currentSeconds
            if remaining <= self.fadeOutDuration && !self.fadeOutStarted {
                self.fadeOutStarted = true
                withAnimation(.easeInOut(duration: self.fadeOutDuration)) {
                    self.overlayOpacity = 1.0
                }
            }
        }
        timeObserverOwner = player
    }

    private func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            (timeObserverOwner ?? player).removeTimeObserver(token)
            timeObserverToken = nil
            timeObserverOwner = nil
        }
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
                        removePeriodicTimeObserver()
                        self.player = AVPlayer(url: saveUrl)
                        self.isVideoReady = true
                        self.player.play()
                        addPeriodicTimeObserver()
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
            removePeriodicTimeObserver()
            self.player = AVPlayer(url: cachedVideoUrl)
            self.isVideoReady = true
            print("Serving video from cache")
        } else {
            guard let videoUrlString = exercise.videoUrl, let videoUrl = URL(string: videoUrlString) else {
                print("Invalid video URL")
                return
            }
            removePeriodicTimeObserver()
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
