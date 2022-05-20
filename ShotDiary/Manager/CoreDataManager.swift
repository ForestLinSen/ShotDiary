//
//  CoreDataManager.swift
//  ShotDiary
//
//  Created by Sen Lin on 4/5/2022.
//

import Foundation
import UIKit

class CoreDataManager{
    private init(){}
    
    static let shared = CoreDataManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getAllItems(completion: @escaping ([DiaryViewModel]?) -> Void){
        do{
            let items = try context.fetch(Diary.fetchRequest())
            
            let viewModels = items.compactMap { diary in
                return DiaryViewModel(title: diary.title!, content: diary.content!, fileURL: diary.fileURL!, date: diary.date!, diaryID: diary.diaryID!)
            }
            
            print("Debug: fetch item -> \(viewModels)")
            completion(viewModels)
        }catch{
            print("Debug: an error occured when fetching Diary data")
            completion(nil)
        }
    }
    
    func createItems(viewModel: DiaryViewModel, completion: @escaping (Bool) -> Void){
        let newItem = Diary(context: context)
        newItem.title = viewModel.title
        newItem.content = viewModel.content
        newItem.fileURL = viewModel.fileURL
        newItem.date = viewModel.date
        newItem.diaryID = viewModel.diaryID
        
        do{
            try context.save()
            completion(true)
        }catch{
            print("Debug: failed to save the new item")
            completion(false)
        }
    }
    
    func deleteItem(for id: UUID, completion: @escaping (Bool) -> Void){
        let fetchRequest = Diary.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "diaryID = %@", id as CVarArg)
        
        do{
            guard let diary = try context.fetch(fetchRequest).first else { return }
            context.delete(diary)
            try context.save()
            completion(true)
        }catch{
            completion(false)
        }
    }
    
    func updateItem(for id: UUID, title: String, content: String, fileName: String){
        let fetchRequest = Diary.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "diaryID = %@", id as CVarArg)
        
        do{
            guard let diary = try context.fetch(fetchRequest).first else { return }
            diary.title = title
            diary.content = content
            diary.fileURL = fileName
            try context.save()
        }catch{
            print("Debug: something wrong when updating the item")
        }
    }
    
    func searchItem(with query: String) -> [Diary] {
        let fetchRequest = Diary.fetchRequest()
        let predicateTitle = NSPredicate(format: "title CONTAINS[c] %@", query)
        let predicateContent = NSPredicate(format: "content CONTAINS[c] %@", query)
        fetchRequest.predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicateTitle, predicateContent])
        
        do{
            let result = try context.fetch(fetchRequest)
            return result
        }catch{
            print("Debug: cannot fetch the data \(error)")
            return []
        }
    }
}
