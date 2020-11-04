//
//  SciencesViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 11/3/20.
//

import Foundation

class SciencesViewModel: TableViewWithTitleViewModel {
    override init() {
        super.init()
        
        self.items = [
            ScienceListItem(title: "Biology", iconName: "plant"),
            ScienceListItem(title: "Chemistry", iconName: "flask"),
            ScienceListItem(title: "Physics", iconName: "diagram", tapHandler: {
                Router.show(SpecificScienceViewController.self, params: ["title": $0])
            }),
            ScienceListItem(title: "Earth science", iconName: "earth")
        ]
    }
}
