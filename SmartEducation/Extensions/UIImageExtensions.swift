//
//  UIImageExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 11/24/20.
//

import Foundation
import UIKit
import SwiftGifOrigin

extension UIImage {
  public class func gif(asset: String) -> UIImage? {
    if let asset = NSDataAsset(name: asset) {
       return UIImage.gif(data: asset.data)
    }
    return nil
  }
}
