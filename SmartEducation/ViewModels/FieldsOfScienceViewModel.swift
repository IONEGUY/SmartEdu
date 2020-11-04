//
//  FieldsOfScienceViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 11/3/20.
//

import Foundation

class FieldsOfScienceViewModel {
    var fieldsOfScience: [ScienceListItem] = []

    init() {
        buildFieldsOfScience()
    }

    private func buildFieldsOfScience() {
        fieldsOfScience = [
            ScienceListItem(title: "Natural sciences", iconName: "leaf", tapHandler: {
                Router.show(SciencesViewController.self, params: ["title": $0])
            }),
            ScienceListItem(title: "Engineering and technology", iconName: "research"),
            ScienceListItem(title: "Agricultural science", iconName: "plant"),
            ScienceListItem(title: "Medical and health science", iconName: "drug"),
            ScienceListItem(title: "Social science", iconName: "monkey")
        ]
    }
}
