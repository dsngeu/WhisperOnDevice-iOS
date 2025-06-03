//
//  PrimaryButton.swift
//  WhisperOnDevice
//
//  Created by Deepak Singh on 03/06/25.
//

import UIKit

@IBDesignable
class PrimaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupStyle()
    }

    private func setupStyle() {
        // Background color: light green
        self.backgroundColor = UIColor(red: 0.75, green: 0.90, blue: 0.75, alpha: 1.0) // light green

        // Corner radius
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        // Title color
        self.setTitleColor(.white, for: .normal)

        // Font style (customize as needed)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        // Optional shadow (if you want it)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
}
