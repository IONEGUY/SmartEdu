//
//  FieldsOfScienceViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/3/20.
//

import UIKit
import Closures

class FieldsOfScienceViewController: UIViewController, MVVMViewController {
    typealias ViewModelType = FieldsOfScienceViewModel

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fieldsOfScienceCollectionView: UICollectionView!

    var viewModel: FieldsOfScienceViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Fields of science"

        configueFieldsOfScienceCollectionView()
    }

    private func configueFieldsOfScienceCollectionView() {
        fieldsOfScienceCollectionView.backgroundColor = .clear
        fieldsOfScienceCollectionView.register(
            UINib(nibName: FieldOfScienceCollectionViewCell.typeName, bundle: nil),
            forCellWithReuseIdentifier: FieldOfScienceCollectionViewCell.typeName)

        let width = fieldsOfScienceCollectionView.bounds.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (width / 2) - 30, height: 106)
        layout.minimumLineSpacing = 20
        fieldsOfScienceCollectionView.collectionViewLayout = layout

        fieldsOfScienceCollectionView
            .numberOfItemsInSection { [weak self] _ in
                self?.viewModel?.fieldsOfScience.count ?? 0 }
            .cellForItemAt { [weak self] index in
                let cell = self?.fieldsOfScienceCollectionView
                    .dequeueReusableCell(withReuseIdentifier: FieldOfScienceCollectionViewCell.typeName,
                                         for: index) as? FieldOfScienceCollectionViewCell
                let fieldOfScience = self?.viewModel?.fieldsOfScience[index.row]
                cell?.initCell(fieldOfScience)
                return cell ?? UICollectionViewCell() }
            .didSelectItemAt { [weak self] index in
                guard let fieldOfScience = self?.viewModel?.fieldsOfScience[index.row] else { return }
                fieldOfScience.tapHandler?(fieldOfScience.title) }
            .reloadData()
    }
}
