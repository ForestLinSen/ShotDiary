//
//  GroupedDiaryViewModel.swift
//  ShotDiary
//
//  Created by Sen Lin on 4/5/2022.
//

import Foundation

class GroupedDiaryViewModel {
    let sectionName: String
    var viewModels: [DiaryViewModel]
    var displayedSectionName: String?

    init(sectionName: String, viewModels: [DiaryViewModel]) {
        self.sectionName = sectionName
        self.viewModels = viewModels

        if let viewModel = self.viewModels.first {
            self.displayedSectionName = viewModel.displayCollectionDate
        }
    }
}
