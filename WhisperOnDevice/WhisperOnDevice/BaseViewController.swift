//
//  BaseViewController.swift
//  WhisperOnDevice
//
//  Created by Deepak Singh on 03/06/25.
//

import UIKit

class BaseViewController: UIViewController, ActionSheetPresentable {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BaseViewController {
    func pushViewController<T: UIViewController>(
        ofType type: T.Type,
        fromStoryboard storyboardName: String = "Main",
        identifier: String,
        animated: Bool = true
    ) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            print("Could not instantiate view controller with ID \(identifier) as \(T.self)")
            return
        }
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
}
