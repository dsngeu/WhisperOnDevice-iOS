//
//  ActionSheetPresentable.swift
//  ActionSheet
//
//  Created by Deepak Singh on 03/06/25.
//  Copyright © 2025 Deepak Singh. All rights reserved.
//

import UIKit

/// A protocol to present alerts and action sheets from any `UIViewController`.
@MainActor
protocol ActionSheetPresentable: AnyObject {
    func showMessage(message: String, title: String, onDismiss: @escaping () -> Void)
    func showActionSheet(title: String?, message: String?, actions: [AlertAction], sourceView: UIView, sourceRect: CGRect, onTap: @escaping (AlertAction) -> Void)
    func showAlert(title: String, message: String, actions: [AlertAction], onTap: @escaping (AlertAction) -> Void)
    func showNetworkError()
}

// MARK: - Default implementation for UIViewController

extension ActionSheetPresentable where Self: UIViewController {

    func showMessage(message: String, title: String = "APP", onDismiss: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            onDismiss()
        })
        present(alert, animated: true)
    }

    func showActionSheet(title: String?, message: String?, actions: [AlertAction], sourceView: UIView, sourceRect: CGRect, onTap: @escaping (AlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for action in actions {
            alert.addAction(UIAlertAction(title: action.title, style: action.style) { _ in
                onTap(action)
            })
        }

        // Add default cancel if not provided
        if !actions.contains(where: { $0.style == .cancel }) {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceRect
            popoverController.permittedArrowDirections = [.up, .down]
        }

        present(alert, animated: true)
    }

    func showAlert(title: String, message: String, actions: [AlertAction], onTap: @escaping (AlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alert.addAction(UIAlertAction(title: action.title, style: action.style) { _ in
                onTap(action)
            })
        }

        present(alert, animated: true)
    }

    func showNetworkError() {
        showMessage(message: "Please check your internet connection and try again.", title: "Network Error") {}
    }
}
