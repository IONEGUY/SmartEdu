//
//  UIColorExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 11/3/20.
//

import Foundation
import UIKit

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }

    convenience init(hex: UInt) {
        let red = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 08) & 0xff) / 255
        let blue = CGFloat((hex >> 00) & 0xff) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    convenience init(hexWithAlpha: UInt) {
        let red = CGFloat((hexWithAlpha & 0xff000000) >> 24) / 255
        let green = CGFloat((hexWithAlpha & 0x00ff0000) >> 16) / 255
        let blue = CGFloat((hexWithAlpha & 0x0000ff00) >> 8) / 255
        let alpha = CGFloat(hexWithAlpha & 0x000000ff) / 255

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
