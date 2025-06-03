//
//  AlertAction.swift
//  ActionSheet
//
//  Created by Deepak Singh on 03/06/25.
//  Copyright © 2025 Deepak Singh. All rights reserved.
//

import UIKit

enum AlertAction {
    case delete
    case signOut
    case cancel
    case custom(title: String, style: UIAlertAction.Style = .default)
    
    var title: String {
        switch self {
        case .delete: return "Delete"
        case .signOut: return "Sign Out"
        case .cancel: return "Cancel"
        case .custom(let title, _): return title
        }
    }

    var style: UIAlertAction.Style {
        switch self {
        case .delete, .signOut: return .destructive
        case .cancel: return .cancel
        case .custom(_, let style): return style
        }
    }
}
