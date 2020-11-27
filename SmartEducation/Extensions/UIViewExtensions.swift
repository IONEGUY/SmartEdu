//
//  UIViewExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 11/10/20.
//

import Foundation
import UIKit

extension UIView {
    @discardableResult
    func applyRoundedStyle(borderColor: UIColor? = nil,
                           cornerRadius: CGFloat? = nil,
                           borderWidth: CGFloat? = nil) -> Self {
        clipsToBounds = false
        layer.borderColor = borderColor?.cgColor ?? UIColor.volumetricItemSelectedColor.cgColor
        layer.cornerRadius = cornerRadius ?? frame.height / 2
        layer.borderWidth = borderWidth ?? 3
        return self
    }

    func applyPulseAnimation() {
        let pulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 40, postion: center)
        pulse.animationDuration = 1
        pulse.name = PulseAnimation.typeName
        pulse.backgroundColor = #colorLiteral(red: 0.05282949957, green: 0.5737867104, blue: 1, alpha: 1)
        superview?.layer.insertSublayer(pulse, below: superview?.layer)
    }

    func removePulseAnimation() {
        superview?.layer.sublayers?.forEach {
            if $0.name == PulseAnimation.typeName {
                $0.removeFromSuperlayer()
            }
        }
    }

    func fillSuperview() {
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = superview.translatesAutoresizingMaskIntoConstraints
        if translatesAutoresizingMaskIntoConstraints {
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            frame = superview.bounds
        } else {
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        }
    }
}
