//
//  GlobalStyles.swift
//  SmartEducation
//
//  Created by MacBook on 11/21/20.
//

import Foundation
import UIKit

class GlobalStyles {
    class func create() {
        setupTransparentNavigationBar()
    }
    
    private class func setupTransparentNavigationBar() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
}
