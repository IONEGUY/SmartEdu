//
//  SpecificScienceViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 11/3/20.
//

import Foundation

class SpecificScienceViewModel: TableViewWithTitleViewModel {
    override init() {
        super.init()
        
        self.items = [
            ScienceListItem(title: "Acoustics"),
            ScienceListItem(title: "Astronomy"),
            ScienceListItem(title: "Mechanics"),
            ScienceListItem(title: "Optics")
        ]
    }
}
