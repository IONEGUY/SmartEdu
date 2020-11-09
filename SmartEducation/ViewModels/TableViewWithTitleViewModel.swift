//
//  TableViewWithTitleViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 11/4/20.
//

import Foundation

class TableViewWithTitleViewModel: NavigatedToAware {
    var title: String?
    var items: [ScienceListItem]?

    func navigatedTo(_ params: [String: Any]) {
        guard let title = params["title"] as? String else { return }
        self.title = title
    }
}
