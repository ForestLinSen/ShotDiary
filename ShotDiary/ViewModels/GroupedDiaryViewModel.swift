//
//  GroupedDiaryViewModel.swift
//  ShotDiary
//
//  Created by Sen Lin on 4/5/2022.
//

import Foundation

class GroupedDiaryViewModel{
    let sectionName: String
    var viewModels: [DiaryViewModel]
    
    init(sectionName: String, viewModels: [DiaryViewModel]){
        self.sectionName = sectionName
        self.viewModels = viewModels
    }
}
