//
//  FieldOfScienceCollectionViewCell.swift
//  SmartEducation
//
//  Created by MacBook on 11/3/20.
//

import UIKit

class FieldOfScienceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var icon: UIImageView?

    func initCell(_ scienceListItem: ScienceListItem?) {
        initView()

        guard let scienceListItem = scienceListItem,
              let image = scienceListItem.iconName else { return }
        title?.text = scienceListItem.title
        icon?.image = UIImage(named: image)
    }

    private func initView() {
        contentView.backgroundColor = .random
        contentView.layer.cornerRadius = 8
    }
}
