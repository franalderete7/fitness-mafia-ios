//
//  LaunchScreenViewControllerRepresentable.swift
//  FitnessMafia
//
//  Created by Assistant on 22/09/2025.
//

import SwiftUI

struct LaunchScreenViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var animationComplete: Bool

    func makeUIViewController(context: Context) -> LaunchScreenViewController {
        return LaunchScreenViewController()
    }

    func updateUIViewController(_ uiViewController: LaunchScreenViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(animationComplete: $animationComplete)
    }

    class Coordinator: NSObject {
        @Binding var animationComplete: Bool

        init(animationComplete: Binding<Bool>) {
            _animationComplete = animationComplete
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(animationDidComplete), name: NSNotification.Name("LaunchScreenAnimationComplete"), object: nil)
        }

        @objc func animationDidComplete() {
            animationComplete = true
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
