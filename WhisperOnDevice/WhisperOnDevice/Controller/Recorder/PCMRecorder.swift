//
//  PCMRecorder.swift
//  WhisperOnDevice
//
//  Created by Deepak Singh on 03/06/25.
//

import UIKit
import AVFoundation
import Accelerate

protocol PCMRecorderDelegate: AnyObject {
    func didReceiveBuffer(bufferData: Data?)
    func didReceiveRecorderError(_ error: Error)
}

class PCMRecorder: NSObject {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private let targetSampleRate: Double = 16_000
    private let channelCount: AVAudioChannelCount = 1
    private var isRecording = false
    private var converter: AVAudioConverter!
    private var pcmAccumulator = Data()
    @Published var level: Float?
    weak var delegate: PCMRecorderDelegate?

    init(delegate: PCMRecorderDelegate?) {
        self.delegate = delegate
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        let avSession = AVAudioSession.sharedInstance()
        
        do {
            // Set category for both playback and recording with echo cancellation & speaker output
            try avSession.setCategory(.playAndRecord,
                                      mode: .voiceChat,
                                      options: [
                                          .defaultToSpeaker,
                                          .allowBluetooth,
                                          .allowBluetoothA2DP,
                                          .mixWithOthers
                                      ])
            
            // Set sample rate and buffer duration
            try avSession.setPreferredSampleRate(16_000)
            try avSession.setPreferredIOBufferDuration(0.005) // 5 ms buffer
            
            try avSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("AVAudioSession configured successfully")
            
        } catch {
            delegate?.didReceiveRecorderError(error)
        }
    }

    func startRecording() {
        guard !isRecording else { return }

        do {
            let engine = AVAudioEngine()
            let inputNode = engine.inputNode
            let hwFormat = inputNode.inputFormat(forBus: 0)
            print("🎙️ Input format: \(hwFormat.sampleRate) Hz, \(hwFormat.channelCount) ch")

            if hwFormat.sampleRate < 16000 || hwFormat.channelCount != 1 {
                delegate?.didReceiveRecorderError(
                    NSError(domain: "MicError", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "Microphone is in use by another app or call."
                    ])
                )
                return
            }

            guard let targetFormat = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: targetSampleRate,
                channels: channelCount,
                interleaved: true
            ) else {
                throw NSError(domain: "AudioError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create target format"])
            }

            converter = AVAudioConverter(from: hwFormat, to: targetFormat)

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: hwFormat) { [weak self] buffer, _ in
                self?.processAudioBuffer(buffer, targetFormat: targetFormat)
            }

            engine.prepare()
            try engine.start()

            self.audioEngine = engine
            self.inputNode = inputNode
            self.isRecording = true
        } catch {
            delegate?.didReceiveRecorderError(error)
            stopRecording()
        }
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, targetFormat: AVAudioFormat) {
        let ratio = targetSampleRate / buffer.format.sampleRate
        let outCapacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 1

        guard let outBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: outCapacity) else {
            return
        }

        var error: NSError?
        let status = converter.convert(to: outBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        guard status == .haveData || status == .inputRanDry,
              let int16Pointer = outBuffer.int16ChannelData?.pointee else {
            return
        }

        let byteCount = Int(outBuffer.frameLength) * 2
        let pcmData = Data(bytes: int16Pointer, count: byteCount)

        // Optional: calculate RMS mic level
        if let channelData = buffer.floatChannelData?[0] {
            var sum: Float = 0
            vDSP_measqv(channelData, 1, &sum, vDSP_Length(buffer.frameLength))
            let rms = sqrtf(sum)
            let dB = 20 * log10(rms)
            level = max(-160, min(0, dB))
        }

        pcmAccumulator.append(pcmData)
        while pcmAccumulator.count >= 3200 {
            let chunk = pcmAccumulator.prefix(3200)
            pcmAccumulator.removeFirst(3200)
            delegate?.didReceiveBuffer(bufferData: Data(chunk))
        }

        if let error = error {
            delegate?.didReceiveRecorderError(error)
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
        converter = nil
        isRecording = false
        pcmAccumulator.removeAll()
        print(" Recording stopped")
    }


    deinit {
        stopRecording()
    }
}
