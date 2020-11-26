//
//  TableViewWithTItleViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/4/20.
//

import UIKit

class TableViewWithTitleViewController<TViewModel: TableViewWithTitleViewModel>: BaseViewController, MVVMViewController {

    var viewModel: TViewModel?
    typealias ViewModelType = TViewModel

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = viewModel?.title

        configueTableView()
    }

    func configueTableView() {
        let count = viewModel?.items?.count ?? 0
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(50 * count)).isActive = true
        tableView.layer.cornerRadius = 8
        tableView.isScrollEnabled = false

        tableView
            .numberOfRows { [weak self] _ in
                self?.viewModel?.items?.count ?? 0 }
            .cellForRow { [weak self] indexPath in
                let cell = UITableViewCell()
                guard let science = self?.viewModel?.items?[indexPath.row] else { return cell }
                cell.backgroundColor = .random
                cell.textLabel?.text = science.title
                cell.textLabel?.textColor = .white
                cell.imageView?.image = UIImage(named: science.iconName ?? String.empty)
                cell.selectionStyle = .none
                return cell }
            .didSelectRowAt { [weak self] index in
                guard let science = self?.viewModel?.items?[index.row] else { return }
                science.tapHandler?(science.title) }
            .heightForRowAt { _ in 50 }
            .reloadData()
    }
}
