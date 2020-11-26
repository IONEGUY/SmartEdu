//
//  VolumetricObjectCollectionViewCell.swift
//  SmartEducation
//
//  Created by MacBook on 11/9/20.
//

import UIKit

class VolumetricObjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var objectImage: UIImageView!
    @IBOutlet weak var objectName: UILabel!

    func setupView(_ volumetricObject: VolumetricObject?) {
        guard let volumetricObject = volumetricObject else { return }
        self.objectImage.image = UIImage(named: volumetricObject.image)
        self.objectName.text = volumetricObject.name
    }
}
