//
//  Helper.swift
//  ShotDiary
//
//  Created by Sen Lin on 3/5/2022.
//

import Foundation

class Helper{
    static func generateVideoFileName() -> String{
        return "\(UUID().uuidString)_\(dateGenerate()).mov"
    }
    
    static func dateGenerate() -> String{
        let dateValue = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let dateString = "\(dateValue.year!)_\(dateValue.month!)_\(dateValue.day!)"
        return dateString
    }
}
