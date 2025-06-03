//
//  RecorderViewController.swift
//  WhisperOnDevice
//
//  Created by Deepak Singh on 03/06/25.
//

import UIKit
import Combine

class RecorderViewController: BaseViewController {

    @IBOutlet weak var buttonRecord: UIButton!
    
    private let viewModel = RecorderViewModel(recordingState: .none)
    private var cancellables = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        bindings()

    }
    
    deinit {
        cancellables.removeAll()
        print("RecorderViewController reinitialized")
    }
    
    // MARK: IBActions
    @IBAction func tapRecord(_ sender: Any) {
        viewModel.updateRecordingState()
    }
}

// MARK: Private
extension RecorderViewController {
    private func bindings() {
        viewModel.$recordingState
            .sink { [weak self] state in
                guard let self = self else { return }
                updateUI(state: state)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(state: RecordingState) {
        buttonRecord.setImage(
            UIImage(named: state == .none ? "record-green" : "record-red"),
            for: .normal
        )
    }
}

