//
//  ViewController.swift
//  WhisperOnDevice
//
//  Created by Deepak Singh on 03/06/25.
//

import UIKit
import AVFoundation

class ViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IBActions
    @IBAction func tapGo(_ sender: Any) {
        checkMicrophonePermission()
    }
}

// MARK: IBActions
extension ViewController {
    private func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Permission granted — proceed")
            showRecorder()
            
        case .denied:
            print("Permission denied — show settings alert")
            showMicrophonePermissionAlert()
            
        case .undetermined:
            print("❓ Permission undetermined — requesting now")
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted {
                        print("Microphone permission granted in request")
                        self.showRecorder()
                    } else {
                        print("Microphone permission denied in request")
                        self.showMicrophonePermissionAlert()
                    }
                }
            }
            
        @unknown default:
            print("Unknown mic permission status")
            showMicrophonePermissionAlert()
        }
    }
    
    private func showMicrophonePermissionAlert() {
        showAlert(
            title: "Microphone Access Needed",
            message: "Please allow microphone access in Settings to use this feature.",
            actions: [
                .cancel,
                .custom(title: "Open Settings", style: .default)
            ]
        ) { action in
            if case .custom(let title, _) = action, title == "Open Settings" {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        }
    }
    
    private func showRecorder() {
        pushViewController(ofType: RecorderViewController.self, identifier: "RecorderViewController")
    }
}
