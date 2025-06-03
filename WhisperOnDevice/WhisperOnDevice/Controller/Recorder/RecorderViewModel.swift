//
//  RecorderViewModel.swift
//  WhisperOnDevice
//
//  Created by Deepak Singh on 03/06/25.
//

import Foundation
import Combine

enum RecordingState {
    case none
    case recording
}

class RecorderViewModel {
    
    @Published var recordingState: RecordingState = .none
    @Published var errorMessage: String?
    private var recorder: PCMRecorder?
    private var pcmContainer = Data()

    
    init(recordingState: RecordingState) {
        self.recordingState = recordingState
    }
    
    func updateRecordingState() {
        switch recordingState {
        case .none:
            startRecording()
        case .recording:
            stopRecording()
        }
        recordingState = (recordingState == .none) ? .recording : .none
    }
}

// Mark: - Private
extension RecorderViewModel {
    private func startRecording() {
        recordingState = .none
        recorder = nil
        recorder = PCMRecorder(delegate: self)
        recorder?.startRecording()
    }
    
    private  func stopRecording() {
        recorder?.stopRecording()
        recorder = nil
        pcmContainer.removeAll()
    }
}
// Mark: - PCMRecorderDelegate
extension RecorderViewModel: PCMRecorderDelegate {
    func didReceiveBuffer(bufferData: Data?) {
        guard let bufferData = bufferData else { return }
        pcmContainer.append(bufferData)
    }
    
    func didReceiveRecorderError(_ error: any Error) {
        errorMessage = error.localizedDescription
    }
}
