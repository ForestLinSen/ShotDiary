//
//  Diary+CoreDataProperties.swift
//  ShotDiary
//
//  Created by Sen Lin on 4/5/2022.
//
//

import Foundation
import CoreData


extension Diary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Diary> {
        return NSFetchRequest<Diary>(entityName: "Diary")
    }

    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var fileURL: String?
    @NSManaged public var date: Date?
    @NSManaged public var diaryID: UUID?

}

extension Diary : Identifiable {

}
